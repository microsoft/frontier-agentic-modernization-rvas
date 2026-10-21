import json
import os
from pathlib import Path
import shlex
import shutil
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "prepare-env.sh"
DERIVED = (
    "MIGRATION_SQL_HOST", "ACA_RG", "ACA_APP", "APP_IDENTITY_NAME",
    "APP_CLIENT_ID", "BLOB_ACCOUNT", "DEMO_IMAGE",
)
MOCK_CLI = """#!/usr/bin/env python3
import json
import os
from pathlib import Path
import sys

config = json.loads(Path(os.environ["MOCK_CONFIG"]).read_text())
args = sys.argv[1:]
command = Path(sys.argv[0]).name
with open(os.environ["MOCK_LOG"], "a") as log:
    log.write(json.dumps([command] + args) + "\\n")
if command == "terraform":
    assert args[1:3] == ["output", "-json"], args
    if config.get("terraform_error"):
        print("backend unavailable", file=sys.stderr)
        sys.exit(1)
    if args[-1] == config.get("bad_output"):
        print(config.get("bad_value", "{}"))
    else:
        print(json.dumps(config["outputs"][args[-1]]))
elif args[:2] == ["containerapp", "list"]:
    assert args[2:] == ["-g", "custom-aca-rg", "-o", "json"], args
    if config.get("azure_error"):
        print("Azure lookup failed", file=sys.stderr)
        sys.exit(1)
    print(json.dumps(config["apps"]))
elif args[:3] == ["storage", "account", "show"]:
    assert args[3:] == [
        "-g", "custom-aca-rg", "-n", "customsa123",
        "--query", "name", "-o", "tsv",
    ], args
    print("customsa123")
else:
    raise AssertionError(args)
"""


class PrepareEnvironmentTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.config = self.root / "config.json"
        self.log = self.root / "calls.jsonl"
        self.bin = self.root / "bin"
        self.bin.mkdir()
        for name in ("terraform", "az"):
            cli = self.bin / name
            cli.write_text(MOCK_CLI)
            cli.chmod(0o755)
        self.data = {
            "outputs": {
                "target_sql_server_for_wizard": "migration.database.windows.net",
                "resource_group_name": "custom-aca-rg",
                "container_app_fqdn": "custom.example.test",
                "storage_account_blob_endpoint": "https://customsa123.blob.core.windows.net/",
            },
            "apps": [
                {"name": "unrelated-app", "properties": {
                    "configuration": {"ingress": {"fqdn": "other.example.test"}}}},
                {
                    "name": "custom-contoso",
                    "properties": {"configuration": {"ingress": {
                        "fqdn": "custom.example.test"}}},
                    "identity": {"userAssignedIdentities": {
                        "/subscriptions/test/resourceGroups/custom-aca-rg/providers/"
                        "Microsoft.ManagedIdentity/userAssignedIdentities/custom-id": {
                            "clientId": "custom-client-id",
                        },
                    }},
                },
            ],
        }

    def run_helper(self, shell, image="registry.example.test/course:demo", stdin=""):
        self.config.write_text(json.dumps(self.data))
        self.log.write_text("")
        env = os.environ.copy()
        env.update({
            "PATH": f"{self.bin}:{env['PATH']}",
            "REPO_ROOT": str(self.root / "repository with spaces"),
            "LEGACY_INFRA": str(self.root / "original legacy deployment"),
            "ACA_INFRA": str(self.root / "original coach deployment"),
            "PREPARE_SCRIPT": str(SCRIPT),
            "MOCK_CONFIG": str(self.config),
            "MOCK_LOG": str(self.log),
            "DEMO_IMAGE": image,
        })
        for name in DERIVED[:-1]:
            env[name] = "stale-value"
        dump = "import json, os; print('\\nENV=' + json.dumps(dict(os.environ)))"
        result = subprocess.run(
            [shell, "-c", 'source "$PREPARE_SCRIPT"; result=$?; '
             f"python3 -c {shlex.quote(dump)}; exit \"$result\""],
            env=env, input=stdin, text=True, capture_output=True,
        )
        exported = json.loads(next(
            line[4:] for line in result.stdout.splitlines() if line.startswith("ENV=")
        ))
        calls = [json.loads(line) for line in self.log.read_text().splitlines()]
        return result, exported, calls

    def shells(self):
        return [shutil.which("bash"), shutil.which("zsh")]

    def test_discovers_custom_resources_and_exports_to_calling_shell(self):
        for shell in self.shells():
            with self.subTest(shell=shell):
                result, env, calls = self.run_helper(shell)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn("Ready:", result.stdout)
                self.assertEqual(env["ACA_APP"], "custom-contoso")
                self.assertEqual(env["ACA_RG"], "custom-aca-rg")
                self.assertEqual(env["APP_IDENTITY_NAME"], "custom-id")
                self.assertEqual(env["APP_CLIENT_ID"], "custom-client-id")
                self.assertEqual(env["BLOB_ACCOUNT"], "customsa123")
                self.assertEqual(env["MIGRATION_SQL_HOST"], "migration.database.windows.net")
                self.assertEqual(env["DEMO_IMAGE"], "registry.example.test/course:demo")
                self.assertEqual(calls[0][1], f"-chdir={env['LEGACY_INFRA']}")
                self.assertEqual(calls[1][1], f"-chdir={env['ACA_INFRA']}")
                self.assertEqual(len(calls), 6)

    def test_prompt_works_in_both_shells(self):
        for shell in self.shells():
            with self.subTest(shell=shell):
                result, env, _ = self.run_helper(shell, image="", stdin="registry.test/app:v2\n")
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(env["DEMO_IMAGE"], "registry.test/app:v2")

    def test_invalid_outputs_stop_before_azure_and_clear_stale_values(self):
        self.data["bad_output"] = "resource_group_name"
        for bad in ("", "{}", "null", '""', '"   "', "Warning: No outputs found"):
            self.data["bad_value"] = bad
            for shell in self.shells():
                with self.subTest(shell=shell, output=bad):
                    result, env, calls = self.run_helper(shell)
                    self.assertNotEqual(result.returncode, 0)
                    self.assertIn("original state", result.stderr)
                    self.assertNotIn("Ready:", result.stdout)
                    self.assertFalse(any(call[0] == "az" for call in calls))
                    self.assertTrue(all(name not in env for name in DERIVED[:-1]))

    def test_terraform_failure_stops_before_azure(self):
        self.data["terraform_error"] = True
        for shell in self.shells():
            with self.subTest(shell=shell):
                result, _, calls = self.run_helper(shell)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(len(calls), 1)

    def test_azure_failure_does_not_export_partial_environment(self):
        self.data["azure_error"] = True
        for shell in self.shells():
            with self.subTest(shell=shell):
                result, env, calls = self.run_helper(shell)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(len(calls), 5)
                self.assertTrue(all(name not in env for name in DERIVED[:-1]))

    def test_wrong_subscription_or_ambiguous_app_is_rejected(self):
        for apps in ([], [self.data["apps"][1]] * 2):
            original = self.data["apps"]
            self.data["apps"] = apps
            for shell in self.shells():
                with self.subTest(shell=shell, apps=len(apps)):
                    result, _, calls = self.run_helper(shell)
                    self.assertNotEqual(result.returncode, 0)
                    self.assertIn("subscription", result.stderr)
                    self.assertEqual(len(calls), 5)
            self.data["apps"] = original

    def test_missing_or_ambiguous_identity_is_rejected(self):
        identity = self.data["apps"][1]["identity"]
        for identities in ({}, {"one": {"clientId": "one"}, "two": {"clientId": "two"}}):
            identity["userAssignedIdentities"] = identities
            for shell in self.shells():
                with self.subTest(shell=shell, identities=len(identities)):
                    result, _, _ = self.run_helper(shell)
                    self.assertNotEqual(result.returncode, 0)
                    self.assertIn("exactly one user-assigned identity", result.stderr)

    def test_empty_image_is_rejected(self):
        for shell in self.shells():
            with self.subTest(shell=shell):
                result, env, _ = self.run_helper(shell, image="", stdin="\n")
                self.assertNotEqual(result.returncode, 0)
                self.assertNotIn("ACA_RG", env)


if __name__ == "__main__":
    unittest.main()

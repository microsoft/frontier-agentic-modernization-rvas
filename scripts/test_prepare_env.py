import json
import os
from pathlib import Path
import shutil
import subprocess
import unittest


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "Coach/demo/dotnet/prepare-env.ps1"


@unittest.skipUnless(shutil.which("pwsh"), "PowerShell 7 is not installed")
class PrepareEnvTests(unittest.TestCase):
    def run_helper(self, scenario):
        harness = r"""
$global:terraformCalls = 0
function terraform {
    $global:terraformCalls++
    $global:LASTEXITCODE = 0
    if ($env:TEST_SCENARIO -eq 'terraform-failure') {
        $global:LASTEXITCODE = 1
        return
    }
    if ($env:TEST_SCENARIO -eq 'invalid-json') { return 'not json' }
    if ($env:TEST_SCENARIO -eq 'array') { return '["unexpected-array"]' }
    switch ($args[-1]) {
        'target_sql_server_for_wizard' { '"student.database.windows.net"' }
        'resource_group_name' { '"coach-rg"' }
        'container_app_fqdn' { '"contoso.example.com"' }
        'storage_account_blob_endpoint' { '"https://demostorage.blob.core.windows.net/"' }
        default { throw "Unexpected Terraform command: $args" }
    }
}
function az {
    $global:LASTEXITCODE = 0
    if ($args[0] -eq 'containerapp') {
        return '[{"name":"contoso","properties":{"configuration":{"ingress":{"fqdn":"contoso.example.com"}}},"identity":{"userAssignedIdentities":{"/identities/demo-id":{"clientId":"demo-client"}}}}]'
    }
    if ($args[0] -eq 'storage') { return 'demostorage' }
    throw "Unexpected Azure command: $args"
}
if ($env:TEST_SCENARIO -eq 'old-powershell') {
    $PSVersionTable.PSVersion = [version]'5.1'
}
$message = ''
$failed = $false
try { . $env:TEST_SCRIPT }
catch { $failed = $true; $message = $_.Exception.Message }
@{
    message = $message
    calls = $global:terraformCalls
    hostName = $env:MIGRATION_SQL_HOST
    app = $env:ACA_APP
    group = $env:ACA_RG
    identity = $env:APP_IDENTITY_NAME
    client = $env:APP_CLIENT_ID
    storage = $env:BLOB_ACCOUNT
} | ConvertTo-Json -Compress
if ($failed) { exit 1 }
"""
        result = subprocess.run(
            ["pwsh", "-NoProfile", "-NonInteractive", "-Command", harness],
            env={
                **os.environ,
                "TEST_SCRIPT": str(SCRIPT),
                "TEST_SCENARIO": scenario,
                "REPO_ROOT": str(ROOT),
                "DEMO_IMAGE": "example.test/demo:rehearsal",
                "MIGRATION_SQL_HOST": "stale-host",
            },
            capture_output=True,
            text=True,
            timeout=30,
        )
        return result, json.loads(result.stdout.strip().splitlines()[-1])

    def test_old_powershell_fails_before_reading_state_or_changing_environment(self):
        result, data = self.run_helper("old-powershell")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("requires PowerShell 7", data["message"])
        self.assertIn("Run pwsh", data["message"])
        self.assertEqual(data["calls"], 0)
        self.assertEqual(data["hostName"], "stale-host")

    def test_json_errors_do_not_suggest_missing_state(self):
        result, data = self.run_helper("invalid-json")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Cannot parse JSON", data["message"])
        self.assertNotIn("state list", data["message"])
        self.assertFalse(data["hostName"])

    def test_single_element_arrays_are_not_accepted_as_string_outputs(self):
        result, data = self.run_helper("array")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("must be a nonempty JSON string", data["message"])

    def test_terraform_errors_retain_deployment_diagnostics(self):
        result, data = self.run_helper("terraform-failure")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Cannot read Terraform output", data["message"])
        self.assertIn("state list", data["message"])

    def test_success_exports_values_to_the_dot_sourcing_terminal(self):
        result, data = self.run_helper("success")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(data["hostName"], "student.database.windows.net")
        self.assertEqual(data["app"], "contoso")
        self.assertEqual(data["group"], "coach-rg")
        self.assertEqual(data["identity"], "demo-id")
        self.assertEqual(data["client"], "demo-client")
        self.assertEqual(data["storage"], "demostorage")
        self.assertIn("Ready:", result.stdout)


if __name__ == "__main__":
    unittest.main()

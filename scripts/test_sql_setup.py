import json
import os
from pathlib import Path
import shutil
import subprocess
import unittest


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "Coach/Solutions/dotnet/infra/setup-sql-user.ps1"


@unittest.skipUnless(shutil.which("pwsh"), "PowerShell 7 is not installed")
class SqlSetupTests(unittest.TestCase):
    def run_setup(self, failures, identity="demo-contoso-id"):
        harness = r"""
$global:calls = 0
$global:sleeps = 0
$global:sqlPath = $null
$global:sqlText = $null
$global:sqlArgs = $null
function sqlcmd {
    $global:calls++
    $global:sqlArgs = @($args)
    $global:sqlPath = $args[([array]::IndexOf($args, '-i') + 1)]
    $global:sqlText = Get-Content -LiteralPath $global:sqlPath -Raw
    $global:LASTEXITCODE = if ($global:calls -le [int]$env:TEST_FAILURES) { 1 } else { 0 }
}
function Start-Sleep { param($Seconds) $global:sleeps++ }
$failed = $false
$message = ''
try { & $env:TEST_SCRIPT }
catch { $failed = $true; $message = $_.Exception.Message }
@{
    calls = $global:calls
    sleeps = $global:sleeps
    sql = $global:sqlText
    arguments = $global:sqlArgs
    cleaned = -not (Test-Path -LiteralPath $global:sqlPath)
    message = $message
} | ConvertTo-Json -Compress
if ($failed) { exit 1 }
"""
        result = subprocess.run(
            ["pwsh", "-NoProfile", "-NonInteractive", "-Command", harness],
            env={
                **os.environ,
                "TEST_SCRIPT": str(SCRIPT),
                "TEST_FAILURES": str(failures),
                "SQL_SERVER": "demo.database.windows.net",
                "SQL_DATABASE": "ContosoUniversity",
                "SQL_IDENTITY": identity,
            },
            capture_output=True,
            text=True,
            timeout=30,
        )
        data = json.loads(result.stdout.strip().splitlines()[-1])
        return result, data

    def test_creates_user_with_entra_auth_and_cleans_up(self):
        result, data = self.run_setup(0, "demo'contoso]id")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(data["calls"], 1)
        self.assertEqual(data["sleeps"], 0)
        self.assertTrue(data["cleaned"])
        self.assertIn("name = N'demo''contoso]id'", data["sql"])
        self.assertIn("CREATE USER [demo'contoso]]id] FROM EXTERNAL PROVIDER", data["sql"])
        for role in ["db_datareader", "db_datawriter", "db_ddladmin"]:
            self.assertIn(f"ALTER ROLE {role} ADD MEMBER", data["sql"])
        self.assertEqual(
            data["arguments"][:-1],
            [
                "-S", "tcp:demo.database.windows.net,1433",
                "-d", "ContosoUniversity",
                "--authentication-method=ActiveDirectoryDefault", "-b", "-i",
            ],
        )

    def test_retries_sql_errors_until_success(self):
        result, data = self.run_setup(2)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(data["calls"], 3)
        self.assertEqual(data["sleeps"], 2)
        self.assertTrue(data["cleaned"])

    def test_exhausted_retries_fail_and_clean_up(self):
        result, data = self.run_setup(10)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(data["calls"], 10)
        self.assertEqual(data["sleeps"], 9)
        self.assertIn("failed after 10 attempts", data["message"])
        self.assertTrue(data["cleaned"])


if __name__ == "__main__":
    unittest.main()

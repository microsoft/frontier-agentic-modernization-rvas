# Coach Guide – Challenge 00: Prerequisites (.NET Track)

## Purpose

This challenge exists to ensure all attendees start from the same baseline for the .NET track. It is largely a logistics/setup challenge and should take no more than 30 minutes.

## Mini-Lecture (5 min before challenge)

Briefly explain:
- The .NET sample application (ContosoUniversity) and its legacy stack: ASP.NET MVC 5 / .NET Framework 4.8 / SQL Express / MSMQ / IIS
- The overall goal of the .NET track — migrate ContosoUniversity using AI-powered tools
- The WTH format: challenge-based, no step-by-step instructions, coach-guided

## Common Issues and Hints

### Submodule folder is empty
The most common issue. After cloning, attendees must run:
```bash
git submodule update --init --recursive
```
If they cloned with `--recurse-submodules`, the submodule should be populated automatically.

### .NET Framework 4.8 build fails on Linux/macOS
The ContosoUniversity project targets .NET Framework 4.8, which is Windows-only. On Linux/macOS, the build will fail with `msbuild`. This is **expected** — the migration in Challenge 02 will move the project to .NET 9. For this challenge, simply verify that the source code is present (submodule initialised) rather than requiring a successful build on non-Windows machines.

### `modernize` CLI not found after install
The install script adds the binary to `~/.local/bin`. Ensure this path is in `$PATH`:
```bash
echo $PATH | grep local
# If not present:
export PATH="$HOME/.local/bin:$PATH"
```

## Success Criteria Notes

- The .NET build check applies only to Windows machines; on Linux/macOS verify the source is present
- All other checks (`gh auth`, `modernize --version`, `az account show`) must pass for all attendees

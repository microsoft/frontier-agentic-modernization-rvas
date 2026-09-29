**[Home](../README.md)**

# Coach Troubleshooting Guide

Track-specific pitfalls stay in each challenge's own coach notes. This page is for issues that
can show up in **any** track, or that need a longer fix than fits inline.

---

## 1. Terraform `apply` fails — `SubscriptionNotRegisteredForFeature` (Azure VM deploy)

**Symptom** (Challenge 00, optional VM deployment, any track):

```
Error: updating Public IP Address (Subscription: "<sub-id>" | Resource Group Name: "wth-photoalbum-vm-rg"
| Public IP Addresses Name: "wth-pip"): performing CreateOrUpdate: unexpected status 400 (400 Bad Request)
with error: SubscriptionNotRegisteredForFeature: Subscription /subscriptions/<sub-id>/resourceGroups//providers/
Microsoft.Network/subscriptions/ is not registered for feature Microsoft.Network/AllowBringYourOwnPublicIpAddress
required to carry out the requested operation.
  with azurerm_public_ip.pip,
  on main.tf line 64, in resource "azurerm_public_ip" "pip":
  64: resource "azurerm_public_ip" "pip" {
```

**Cause:** The subscription hasn't opted in to the `Microsoft.Network/AllowBringYourOwnPublicIpAddress`
preview feature, which the Terraform config's `azurerm_public_ip` resource requires.

**Fix:**

### Step 1 — Request feature registration
Run this if you're authorized to change subscription features (Owner/Contributor on the subscription,
or ask your Azure admin to run it):
```bash
az feature register --subscription <id> --namespace Microsoft.Network --name AllowBringYourOwnPublicIpAddress
```

### Step 2 — Check registration status
```bash
az feature show --subscription <id> --namespace Microsoft.Network --name AllowBringYourOwnPublicIpAddress \
  --query properties.state --output tsv
```
- **`Registering`** → wait a few minutes, then check again.
- **`Registered`** → proceed to Step 3.
- **`Pending`** → Azure service-team approval is required; involve your governance team or open an Azure support ticket.
- **`Authorization failure`** → only a subscription administrator can perform this — ask your Azure admin to run Step 1.

### Step 3 — Re-register the resource provider and retry
```bash
az provider register --namespace Microsoft.Network
terraform apply
```

**Workaround (no time to wait for registration):** If a team is blocked, skip the optional VM
deployment in Challenge 00 — it isn't required for the core modernization track — and revisit
it later once the feature is registered.

---

## 2. AppCat install blocked by NuGet policy

**Symptom** (Challenge 01, .NET track):

- Installing the AppCat (`.NET Upgrade Assistant` / App Modernization) tool fails with:

  ```
  ERROR: Pre-assessment failed: Failed to install .NET tool ... unhandled exception:
  Unable to load the service index for source https://api.nuget.org/v3/index.json.
  ```

**Cause:** Corporate device/network policy may block direct access to the public
`https://api.nuget.org/v3/index.json` feed.

**Fix:**

1. Point the NuGet source at the internal proxy mirror instead of the public feed:

   ```bash
   dotnet tool install --tool-path "<AppCat tools path>" --add-source https://packagefeedproxy.microsoft.io/nuget/v3/index.json dotnet-appcat
   ```

2. If the automatic `modernize assess` pre-assessment step keeps failing, install AppCat manually first with the command above, then re-run:

   ```bash
   modernize assess --source "<path-to-repo>"
   ```

**Note for coaches:** confirm which shell reproduces the issue before troubleshooting further —
this is a device/network policy difference, not a bug in `modernize` or AppCat itself.

---

## Common Issues Across All Challenges

| Issue | Resolution |
|---|---|
| `gh auth status` fails | Run `gh auth login` and complete browser OAuth flow |
| Submodules empty after clone | Run `git submodule update --init --recursive` |
| Docker not running | Ensure Docker Desktop is started before any `docker-compose` or Dev Container commands |
| `modernize` command not found | Re-run the install script; ensure `~/.local/bin` is on `PATH`: `export PATH="$HOME/.local/bin:$PATH"` |
| Azure CLI not logged in | Run `az login` |
| `modernize assess` hangs | Check `gh auth status` — the tool requires an active GitHub session |
| Terraform fails on `az login` | Ensure `ARM_USE_CLI=true` is set or run `az login` before `terraform apply` |

---

*Found a new cross-cutting issue during an event? Add it to this file so future coaches benefit.*

**[Home](../../README.md)** | [Next Solution >](./Solution-01.md) | [Troubleshooting](../TROUBLESHOOTING.md)

# Coach Guide – Challenge 00: Prerequisites (Java Track)

## Purpose

This challenge exists to ensure all attendees start from the same baseline for the Java track. It is largely a logistics/setup challenge and should take no more than 30 minutes.

## Mini-Lecture (5 min before challenge)

Briefly explain:
- The Java sample application (PhotoAlbum) and its legacy stack: Spring Boot 2.7 / Java 8 / Oracle Database / Docker
- The overall goal of the Java track — migrate PhotoAlbum using AI-powered tools
- The WTH format: challenge-based, no step-by-step instructions, coach-guided

## Common Issues and Hints

### Submodule folder is empty
The most common issue. After cloning, attendees must run:
```bash
git submodule update --init --recursive
```
If they cloned with `--recurse-submodules`, the submodule should be populated automatically.

### Oracle container fails to start
Oracle XE requires at least **4 GB RAM** allocated to Docker. Ask attendees to check Docker Desktop → Settings → Resources → Memory. If RAM is insufficient, they can skip the Java local run check and proceed — the assessment and plan steps do not require the Oracle container to be running.

### `modernize` CLI not found after install
The install script adds the binary to `~/.local/bin`. Ensure this path is in `$PATH`:
```bash
echo $PATH | grep local
# If not present:
export PATH="$HOME/.local/bin:$PATH"
```

### Terraform `apply` fails during the optional VM deployment
If a team attempts the optional Azure VM deployment (`Student/Resources/java/infra/`) and
`terraform apply` fails with `SubscriptionNotRegisteredForFeature` on the public IP resource,
see **[Troubleshooting → Terraform apply fails](../TROUBLESHOOTING.md#1-terraform-apply-fails--subscriptionnotregisteredforfeature-azure-vm-deploy)**.
This is a subscription feature-registration gap, not a Terraform config bug — it can take time
to resolve, so don't let it block the core (non-VM) challenge track.

## Success Criteria Notes

- The Java app local run check can be skipped if Docker memory is insufficient — use judgment
- All other checks (`gh auth`, `modernize --version`, `az account show`) must pass for all attendees

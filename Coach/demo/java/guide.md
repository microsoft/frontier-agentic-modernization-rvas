# PhotoAlbum Java Migration - Live Speaker Guide

**55 minutes | Java developers and architects | Bash, Java 25, VS Code**

**First run:** Expand **Pre-demo setup and reference** below. Deploy both stacks, prepare the migration target, and rehearse before presenting. The dedicated **Troubleshooting** chapter remains at the end.

<details>
<summary><strong>Pre-demo setup and reference (complete before presenting)</strong></summary>

Allow **at least 2 hours**. Oracle initialization alone can take 3-5 minutes; cloud provisioning and tool installation take longer. After setup, continue to **Before Starting the Clock** below.

## A0 - Presenter Machine and Terraform State

Use a Bash terminal with Git, the modernization CLI/extension, Java 25, Maven, Terraform, Azure CLI, and Docker. The **VM** needs Ora2Pg, Oracle Instant Client/`DBD::Oracle`, and `psql`; cloud-init attempts to install them, but check them during rehearsal rather than assuming success.

```bash
git clone https://github.com/microsoft/frontier-agentic-modernization-rvas.git
cd frontier-agentic-modernization-rvas
git submodule update --init --recursive
export REPO_ROOT="$PWD"
az login
```

Keep the original Terraform state, backend, workspace, and `terraform.tfvars` for **both** stacks. If resuming, use those deployment directories; a new clone does not recover local state. Do not apply from empty state to recreate existing resources.

## A1 - Deploy the Legacy VM

The Student stack provisions Ubuntu, Docker, Oracle, and the legacy PhotoAlbum containers. It also creates a separate PostgreSQL migration target.

```bash
cd "$REPO_ROOT/Student/Resources/java/infra"
test -f terraform.tfvars || cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
prefix              = "demo"
location            = "swedencentral"
admin_username      = "azureuser"
resource_group_name = "demo-photoalbum-vm-rg"
```

Set `admin_password` and the Student `db_admin_password` privately. Use strong, unique values that meet the variable constraints; replace example defaults. Do not commit credentials or Terraform state.

```bash
terraform init
terraform apply
terraform output
```

Record `public_ip`, `app_url`, and `ssh_command`. Connect using the exact `ssh_command` output and the configured VM password.

## A2 - Stage the Legacy Data and Migration Tools

In **VM Bash**:

```bash
sudo docker compose -f /opt/photoalbum/docker-compose.yml ps
sudo docker compose -f /opt/photoalbum/docker-compose.yml logs -f oracle-db
```

Expect `photoalbum-oracle` healthy and `photoalbum-java-app` running. Wait for `DATABASE IS READY TO USE!`, then press Ctrl+C. Open the Student `app_url` and upload **3-5 recognizable photos**.

Check the export tools:

```bash
ora2pg --version
perl -MDBD::Oracle -e 'print "DBD::Oracle ready\n"'
psql --version
```

Copy `Coach/Solutions/java/ora2pg.conf` from the presenter clone to a working directory on the VM using your SSH/SCP client. Check its connection details against the running Oracle container: host `localhost`, port `1521`, service **`FREEPDB1`**, schema/user `PHOTOALBUM`/`photoalbum`. Keep credentials private. Ora2Pg directives use whitespace, not `=`.

Rehearse an export and inspect the generated schema, owner, sequences, indexes, and photo binary representation. Keep saved exports and source row counts as checkpoints. Do not discover missing Oracle client libraries during the audience session.

## A3 - Deploy the Modern App and Choose the Target

From the **presenter terminal**:

```bash
cd "$REPO_ROOT/Coach/Solutions/java/infra"
test -f terraform.tfvars || cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
prefix              = "demo"
location            = "swedencentral"
app_image           = "ghcr.io/microsoft/frontier-agentic-modernization-rvas/photo-album:latest"
db_admin_username   = "photoalbumadmin"
resource_group_name = "demo-photoalbum-aca-rg"
```

Set the Coach `db_admin_password` privately. It does not need to match the VM password.

```bash
terraform init
terraform apply
terraform output
```

Open the Coach `app_url` and test an upload, image display, and AI enrichment.

**Two PostgreSQL servers:** This guide imports into the **Coach** `postgresql_fqdn`, the server configured for the Container App. The Student `target_postgresql_fqdn` is a different server. Importing there does not automatically reconnect the app.

Before the live run, prepare an **empty Coach migration database** and keep the modern app stopped until import/schema preparation is complete. Do this during setup, not by improvising a destructive reset live. The reference defaults to `spring.jpa.hibernate.ddl-auto=create`: configure the migrated app with **`SPRING_JPA_HIBERNATE_DDL_AUTO=validate`** before it starts against migrated data.

Rehearse the owner/schema mapping and any additive AI schema changes. Ora2Pg output must match the schema and binary mapping the migrated app actually uses.

**Reference limits:** Photo bytes remain in the database; the checked-in Java reference does not implement Blob Storage. Its system-assigned identity accesses Key Vault and OpenAI; PostgreSQL still uses a password, supplied through secret configuration. The Dockerfile does not attach an Application Insights Java agent. Do not promise those additional migrations unless you implemented and tested them.

## A4 - Stage Screens and Checkpoints

| Screen | Ready to show |
|---|---|
| Tab 1 | Student legacy `app_url`, gallery with recognizable photos |
| Tab 2 | Azure Portal: Coach PostgreSQL, Key Vault, Container App, and logs |
| Tab 3 | Coach `app_url`; keep hidden until the reveal |
| VS Code | `Student/Resources/java/PhotoAlbum-Java`, `pom.xml`, assessment terminal |
| VM SSH | Working directory containing the adjusted `ora2pg.conf` |

Keep a saved assessment report, reviewed plan, tested migrated working copy, built image tag, and migration results. Sign Docker into your registry if deploying a live-built image.

At minute 33, stop an unfinished agent run and switch to the tested migrated copy, naming the checkpoint. At minute 40, if export/import is unfinished, show saved results instead of claiming a live migration. At minute 43, if tested code/image or schema preparation is incomplete, skip live cutover and use rehearsed screenshots/results. Do not start the app against an incomplete database.

## Quick Reference

Record these Terraform outputs privately; keep passwords separately.

| Student outputs | Coach outputs |
|---|---|
| `public_ip`, `app_url`, `ssh_command` | `app_url`, `postgresql_fqdn`, `postgresql_server_name` |
| VM username from `terraform.tfvars` | `resource_group_name`, `key_vault_uri` |
| Student target is not used in this flow | `openai_endpoint`, `openai_deployment_name` |

Keep the Coach `db_admin_username` beside the outputs. The examples use `photoalbumadmin`; do not substitute the Student default `psqladmin`.

</details>

## Before Starting the Clock

Open **Bash at the root of this cloned repository**. Run commands one at a time and stop on any error or missing output:

```bash
export REPO_ROOT="$PWD"
test -f "$REPO_ROOT/Coach/Solutions/java/ora2pg.conf"
export LEGACY_INFRA="${LEGACY_INFRA:-$REPO_ROOT/Student/Resources/java/infra}"
export ACA_INFRA="${ACA_INFRA:-$REPO_ROOT/Coach/Solutions/java/infra}"
export VM_IP="$(terraform -chdir="$LEGACY_INFRA" output -raw public_ip)"
export LEGACY_URL="$(terraform -chdir="$LEGACY_INFRA" output -raw app_url)"
export APP_URL="$(terraform -chdir="$ACA_INFRA" output -raw app_url)"
export PGHOST="$(terraform -chdir="$ACA_INFRA" output -raw postgresql_fqdn)"
export ACA_RG="$(terraform -chdir="$ACA_INFRA" output -raw resource_group_name)"
export PG_SERVER="$(terraform -chdir="$ACA_INFRA" output -raw postgresql_server_name)"
```

`REPO_ROOT` is the clone path; the other values come from the original Terraform deployments. Set `LEGACY_INFRA`/`ACA_INFRA` first if their state lives elsewhere. Keep this terminal open; rerun preflight in a new one. **Exports do not cross SSH:** the VM prompts for its PostgreSQL settings in Segment 4.

| Segment | Time | Show |
|---|---|---|
| 1 - Legacy app | 0:00-5:00 | Photo gallery and legacy dependencies |
| 2 - Assessment | 5:00-15:00 | Runtime, persistence, and configuration findings |
| 3 - Code migration | 15:00-33:00 | Reviewed plan, changed code, build/tests |
| 4 - Data and AI | 33:00-48:00 | Ora2Pg export/import and optional enrichment |
| 5 - Reveal | 48:00-55:00 | Validated gallery and deployed application |

## Demo 1: From Oracle on a VM to PostgreSQL on Container Apps

**WOW moment:** Open recognizable legacy photos in the migrated app, then upload a new photo and show saved AI-generated metadata.

### 1 - Show the Legacy App (0:00-5:00)

1. In **Tab 1**, show the prepared photos and upload one more.
2. In VS Code, show `pom.xml`: Java `1.8`, Spring Boot `2.7.18`, and `ojdbc8`.
3. Point to database-backed photo storage and credentials/configuration that need to change.

**Say:**
> The app works. We will change its runtime, database, configuration, and hosting while preserving the photos.

### 2 - Assess (5:00-15:00)

In the **presenter terminal**:

```bash
cd "$REPO_ROOT/Student/Resources/java/PhotoAlbum-Java"
modernize assess --source .
```

Alternatively, use **Recommended Assessment** in the extension. Review runtime upgrades, Oracle persistence, and configuration secrets; inspect code for patterns the report misses.

**Say:**
> The report gives us a starting point. We still inspect the code and review what the migration needs to preserve.

If assessment overruns, show the saved report and identify it as a rehearsal result.

### 3 - Plan, Migrate, and Check (15:00-33:00)

1. Generate the plan, or use **Create Plan** in the report:

```bash
modernize plan create "Create the full Azure modernization plan to Azure Container Apps" --source .
```

2. Review Java 25/Spring Boot 3 migration, Oracle-to-PostgreSQL schema and binary compatibility, secrets, configurable secure endpoints, and dependency/CWE/CVE findings. Preserve photo records and replace destructive Hibernate schema creation with validation.

```bash
modernize plan execute "Execute the plan migrating to Java 25 and PostgreSQL"
```

3. Inspect the diff and build:

```bash
mvn clean package -DskipTests
```

**Check:** `BUILD SUCCESS` is a compile/package checkpoint, not a test result. Run the available tests and check upload, gallery, and image download against the migrated schema.

**Say:**
> Copilot accelerates the edits. We review the plan and diff, then check behavior rather than treating compilation as proof.

At minute 33, stop an unfinished run and switch to the rehearsed migrated copy. Say so, and change the terminal directory to that copy.

### 4 - Move Data and Add AI (33:00-48:00)

**Say:**
> Ora2Pg exports Oracle schema and data; importing it is separate from changing the Java code. This is an offline migration.

1. Finish uploads and stop source writes. In **VM Bash**, stop only the application, leaving Oracle running:

```bash
sudo docker compose -f /opt/photoalbum/docker-compose.yml stop photoalbum-java-app
```

Record the source `PHOTOALBUM.PHOTOS` count using the rehearsed Oracle connection. In the VM directory containing the adjusted `ora2pg.conf`, export:

```bash
ora2pg -c ora2pg.conf -o photoalbum.sql
ora2pg -c ora2pg.conf -t COPY -o data.sql -u system -w photoalbum
```

Use the actual configured Oracle credentials; the template command assumes the sample's `system` password. Inspect generated files before import.

2. Still in **VM Bash**, enter the **Coach** target values from the quick reference:

```bash
read -r -p "Coach postgresql_fqdn: " PGHOST
read -r -p "Coach db_admin_username: " PGUSER
read -r -s -p "Coach database password: " PGPASSWORD
printf '\n'
export PGHOST PGUSER PGPASSWORD
export PGDATABASE=photoalbum PGSSLMODE=require
```

For the template's `OWNER photoalbum`, create the owner role **only if absent**, then grant it to the configured administrator. It does not need a login password:

```bash
psql -v ON_ERROR_STOP=1 -v admin="$PGUSER" <<'SQL'
CREATE ROLE photoalbum NOLOGIN;
GRANT photoalbum TO :"admin";
SQL
```

Import into the prepared empty target. Run each command separately and stop on error:

```bash
psql -v ON_ERROR_STOP=1 < TABLE_photoalbum.sql
psql -v ON_ERROR_STOP=1 < SEQUENCE_photoalbum.sql
psql -v ON_ERROR_STOP=1 < data.sql
psql -v ON_ERROR_STOP=1 < INDEX_photoalbum.sql
unset PGPASSWORD
```

Check the generated schema name/search path, photo count, filenames, binary data, and sequence behavior against the source. Use the schema-qualified `photos` table from the export; do not assume it is in `public`.

3. If time permits, give the plan agent this prompt; otherwise review the rehearsed implementation:

```text
Infuse Azure OpenAI vision into the photoAlbum Spring Boot app. Inspect the
workspace and produce an implementation plan.

Feature: every uploaded photo is auto-analyzed by Azure OpenAI gpt-4.1-mini (vision)
and enriched with a short caption (<120 chars), an accessibility alt-text, and 5-10
lowercase single-word tags. These render on the gallery cards and detail page, and the
<img alt> uses the AI alt-text (falling back to the original filename). Include the
database schema updates, service layer, and UI changes.

Hard requirements:
1. Authenticate with Managed Identity.
2. No API keys or hardcoded endpoints.
3. AI failure must not prevent a photo upload.
4. Apply non-destructive schema changes to the populated database; never recreate it.
5. Build and test successful and failed enrichment.
```

Review/execute the plan and apply its additive schema changes. The reference stores `caption`, `alt_text`, and `tags`; inspect the migrated model before applying changes.

4. Deploy the tested migrated image, not merely the pre-built reference. Check the deployed image tag, Coach database connection, schema mapping, and **`SPRING_JPA_HIBERNATE_DDL_AUTO=validate`** before starting it against migrated data. Wait for a healthy revision and test the gallery.

If export/import is unfinished at minute 40, show saved migration results. If the tested image/schema is not ready at 43, skip live cutover. Label screenshots, rehearsal checkpoints, and the pre-built Coach image honestly; none proves a live migration.

### 5 - Reveal (48:00-55:00)

1. Compare the already-loaded **Tab 1** with **Tab 3**; do not refresh the stopped legacy app.
2. After successful import and deployment, find the same photos and open/download them. Otherwise, explain which checkpoint you are showing.
3. Upload a new photo. Show saved caption, alt text, and tags; the image should still save if AI is unavailable.
4. Show the actual connection, managed identity, Key Vault, and application logs. Do not claim PostgreSQL passwordless authentication, Blob Storage, or Java-agent telemetry unless those changes were implemented.

**Say:**
> We changed the runtime and database, checked the original photos, and added optional AI enrichment. The developer reviewed the changes and validated the result.

**Transition to questions:** Recap the changed dependencies, then use the troubleshooting chapter below if an audience question needs a concrete diagnostic.

## Troubleshooting

### Oracle Container Not Healthy on the VM

Connect using the recorded `ssh_command`. In **VM Bash**:

```bash
sudo docker compose -f /opt/photoalbum/docker-compose.yml ps
sudo docker compose -f /opt/photoalbum/docker-compose.yml logs oracle-db | tail -30
```

Wait for `DATABASE IS READY TO USE!`; first initialization can take 3-5 minutes. If Ora2Pg cannot load its driver, check `DBD::Oracle`, Oracle Instant Client, and `/etc/profile.d/oracle-instantclient.sh` before retrying.

### `modernize` Command Not Found

In the **presenter terminal**:

```bash
export PATH="$HOME/.local/bin:$PATH"
command -v modernize
```

Add the PATH export to `~/.bashrc` or `~/.zshrc` to persist it. If the CLI is not installed, use the prepared extension or saved assessment rather than installing tools live.

### `mvn clean package` Fails After Migration

Check in order:

1. Missed Java EE `javax.*` imports: complete their Jakarta migration; do not blindly replace Java SE packages.
2. Oracle dialect still configured: check the PostgreSQL dialect and datasource settings.
3. `ojdbc8` still in `pom.xml`: replace it with `org.postgresql:postgresql`.
4. Wrong active JDK: check `java -version` and `mvn -version`.
5. Compare with `Coach/Solutions/java/PhotoAlbum-Java/`.

For startup/schema errors, check the exported schema, binary mapping, AI columns, and `ddl-auto=validate`. Never fix missing columns by switching to `create` on populated data.

### `psql` Connection Refused to Azure PostgreSQL

Check hostname, port 5432, SSL, and credentials first. In the **presenter terminal**, use the preflight's Coach resource/server variables to allow the **machine running psql**:

```bash
read -r -p "Public outbound IPv4 of the machine running psql: " CLIENT_IP
az postgres flexible-server firewall-rule create \
  --resource-group "$ACA_RG" \
  --name "$PG_SERVER" \
  --rule-name "AllowDemoMigration" \
  --start-ip-address "$CLIENT_IP" \
  --end-ip-address "$CLIENT_IP"
```

For VM imports, use the VM's outbound IP, not the presenter's. Remove the temporary rule after the demo:

```bash
az postgres flexible-server firewall-rule delete \
  --resource-group "$ACA_RG" --name "$PG_SERVER" \
  --rule-name "AllowDemoMigration" --yes
```

| Symptom | Check |
|---|---|
| Ora2Pg exports no photos | Source service/schema, Oracle readiness, and privileges |
| Import errors or different row counts | Stop; inspect generated SQL and owner/schema mapping before cutover |
| Gallery is empty after restart | Wrong server/schema or destructive Hibernate schema creation |
| AI is unavailable | Logs, endpoint/deployment, managed identity access; uploads must still work |

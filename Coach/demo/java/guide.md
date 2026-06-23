# PhotoAlbum Java Migration — Demo Speaker Guide

**Duration**: 55 minutes  
**Audience**: Technical (Java developers, architects)  
**Pitch**: Migrate a legacy Spring Boot 2.7 / Java 8 / Oracle app to Spring Boot 3.x / Java 21 / Azure PostgreSQL, secured with Key Vault + Managed Identity, hosted on Azure Container Apps.

## Timing

| | Description | Time |
|---|---|---|
| **Part A** | Pre-demo setup *(before audience arrives — allow 60 min)* | — |
| **S1** | Scene Setting — show the legacy app running | 0:00 – 5:00 |
| **S2** | Assessment — `modernize assess` | 5:00 – 15:00 |
| **S3** | Code Migration — GitHub Copilot live | 15:00 – 33:00 |
| **S4** | Database Migration — Ora2Pg | 33:00 – 48:00 |
| **S5** | The Reveal — modern app on Azure Container Apps | 48:00 – 55:00 |

## Quick Reference — Fill In Before the Demo

After running Terraform in Part A, copy these values here:

```
LEGACY VM
  public_ip         = ___________________________________________
  app_url           = http://______________________________:8080
  ssh_command       = ssh azureuser@________________________

AZURE TARGET  (Coach/Solutions/java/infra outputs)
  app_url           = https://___________________________________
  postgresql_fqdn   = ___________________________________________
  postgresql_server = ___________________________________________
  key_vault_uri     = https://___________________________________
  resource_group    = ___________________________________________
  db_admin_user     = photoalbumadmin
  db_admin_password = (value you set in terraform.tfvars)
```

## Part A — Pre-Demo Setup

> Complete all steps at least **2 hours before** the demo starts.  
> Oracle takes 3–5 minutes to initialise on first boot — start early.

### A0 — Set Up Your Local Environment

```bash
# Clone the demo repo and solutions branch
git clone https://github.com/microsoft/frontier-agentic-modernization-hackathon.git
cd frontier-agentic-modernization-hackathon
git submodule update --init --recursive
```

### A1 — Deploy the Legacy VM

This provisions an Ubuntu VM with Docker, Oracle XE, and the legacy PhotoAlbum app running as containers.

```bash
cd Student/Resources/java/infra
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set:

```hcl
prefix               = "demo"
location             = "swedencentral"
admin_username       = "azureuser"
admin_password       = "DemoP@ssword123!"   # 12+ chars, upper+lower+digit+special, no underscores
resource_group_name  = "demo-photoalbum-vm-rg"
```

Deploy:

```bash
terraform init
terraform apply   # confirm with 'yes' — takes ~5 minutes
```

Copy the outputs to the Quick Reference section above:

```bash
terraform output   # shows public_ip, app_url, ssh_command
```

### A2 — Verify the Legacy App on the VM

SSH into the VM using the `ssh_command` output. Enter the `admin_password` when prompted:

```bash
ssh azureuser@<public_ip>
```

Check that both containers are running:

```bash
sudo docker compose -f /opt/photoalbum/docker-compose.yml ps
```

Expected output: both `photoalbum-oracle` (**healthy**) and `photoalbum-java-app` (**running**) are up.

If Oracle is still initialising, follow its log and wait for the ready message:

```bash
sudo docker compose -f /opt/photoalbum/docker-compose.yml logs -f oracle-db
# Wait until you see:  DATABASE IS READY TO USE!
# Press Ctrl+C when ready
```

Open a browser and navigate to `http://<public_ip>:8080`.  
**Upload 3–5 test photos** — this is the data you will migrate to Azure PostgreSQL in Segment 4.

Exit the VM:

```bash
exit
```

### A4 — Deploy Azure Target Infrastructure

This provisions all Azure resources: Container Apps, PostgreSQL Flexible Server, Azure Blob Storage, Key Vault, Application Insights, Azure OpenAI, and the Container App with the modern image pre-deployed.

```bash
cd Coach/Solutions/java/infra
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
prefix            = "demo"
location          = "swedencentral"
app_image         = "ghcr.io/microsoft/frontier-agentic-modernization-hackathon/photo-album:latest"
db_admin_username = "photoalbumadmin"
db_admin_password = "DemoP@ssword123!"   # must match password used in A1 for consistency
resource_group_name  = "demo-photoalbum-aca-rg"
```

Deploy:

```bash
terraform init
terraform apply   # takes 10–15 minutes — run this while Oracle initialises locally
```

Copy all outputs to the Quick Reference section above:

```bash
terraform output
```

Open the `app_url` in a browser — you should see the modern PhotoAlbum running on Azure Container Apps. 

### A5 — Stage Browser Tabs and VS Code

Open these **before** the demo starts:

| Tab | URL | Notes |
|---|---|---|
| **Tab 1** — Legacy VM | `http://<vm_public_ip>:8080` | Keep visible at the start |
| **Tab 2** — Azure Portal | `https://portal.azure.com` | Pre-navigate to Key Vault and App Insights |
| **Tab 3** — ACA app | `https://<app_url>` | **Minimise — this is the final reveal** |

In VS Code, open `Student/Resources/java/PhotoAlbum-Java` as the working folder. Have the integrated terminal ready in that directory.

## Part B — Live Demo

### Segment 1 — Scene Setting **(0:00 – 5:00)**

**Pitch:**

> This is PhotoAlbum — a Spring Boot application running on Java 8 with an Oracle database, deployed to a virtual machine. Classic enterprise setup from a few years ago.
>
> Let me show you the problems. Java 8 reached end-of-life. Spring Boot 2.7 is no longer maintained. The Oracle JDBC driver requires a licensed account to download — you cannot pull it automatically in a CI/CD pipeline. And photos are stored as binary BLOBs directly inside the database — the worst possible pattern for cloud-native storage. No path to scale, no managed infrastructure, no observability.
>
> We're going to fix all of that, right now, with the help of GitHub Copilot.

**Steps:**

1. Open **Tab 1** — show the legacy app at `http://<vm_public_ip>:8080`, gallery with test photos visible
2. Upload a new photo live — it appears in the gallery
3. Switch to VS Code — open `pom.xml`
4. Point out these three lines:
   - `<java.version>1.8</java.version>`
   - `<artifactId>spring-boot-starter-parent</artifactId>` version `2.7.18`
   - `<artifactId>ojdbc8</artifactId>` (Oracle JDBC)

**Audience sees:** A working but legacy app. Java 8, Oracle dependency, no cloud-native architecture.

### Segment 2 — Assessment **(5:00 – 15:00)**

**Pitch:**

> Before we write a single line of code, let's understand exactly what we're dealing with. The `modernize` CLI will analyse the entire codebase and surface every migration blocker — automatically.

**Steps:**

Open the VS Code terminal and run the assessment or use the GitHub Copilot modernization extension:

```bash
cd Student/Resources/java/PhotoAlbum-Java
modernize assess --source .
```

or start a "Recommended Assessment" in the Copilot extension.

Once you have the results, open the assessment report in VS Code and walk through the findings. Hit these points:

1. **Java Version Upgrade**  
   > *The application is using a Java version that has reached the end of support. It is strongly recommended to plan and execute a migration strategy to upgrade your application to a supported Java version. Supported Java versions receive long-term support (LTS) from the Java community, including bug fixes and updates. Migrating to a supported version provides you with a stable and well-maintained platform for your application.*

2. **Oracle database found**
   > *Oracle database found. To migrate a Java application that uses an Oracle database to Azure*

3. **Password found in configuration file**  
   > *Using clear passwords in property files is a security risk, as they can be easily compromised if the files are accessed by unauthorized individuals.*

### Segment 3 — AI-Assisted Code Migration **(15:00 – 33:00)**

**Pitch:**

> Now we create a migration plan. The `modernize` CLI analyses the assessment output and generates a structured list of tasks. Each one mapped to a specific file or pattern. Then Copilot executes every task in the plan.

**Step 1 — Generate the migration plan:**

```bash
modernize plan create "Create the full Azure modernization plan to Azure Container Apps" --source .
```

or if using the Copilot extension, click "Create Plan" from the assessment report.

Show the generated plan. Walk through the task list and point out the four key items the agent will execute:
- Run on a supported, current Java LTS runtime for long-term maintainability and security.
- Remove plaintext secrets by sourcing credentials from Azure Key Vault.
- Migrate persistence from Oracle to Azure Database for PostgreSQL, secured with Managed Identity.
- Replace insecure protocols, hardcoded URLs, and localhost resource access with cloud-ready,
  externally configurable, secure endpoints.
- Remediate known CWE weaknesses and CVE vulnerabilities prior to deployment.

**Step 2 — Agent executes the plan:**

```bash
modernize plan execute "Execute the plan migrating to Java 21 and PostgreSQL"
```

or ask the agent in the Copilot extension to: "Execute the plan".

**Step 3 — Verify the build:**

```bash
mvn clean package -DskipTests
```

**Audience sees:** `BUILD SUCCESS` — the migrated code compiles cleanly with Java 21 and Spring Boot 3.

**Pitch:**

> "The plan had everything. Copilot executed each task. We reviewed and accepted. The build passes."

### Segment 4 — Database Migration **(33:00 – 48:00)**

**Pitch:**

> "The code compiles. Now the data. Our source is Oracle — running locally in Docker. Our target is Azure Database for PostgreSQL Flexible Server, already provisioned in Azure. We will use Ora2Pg — the industry-standard Oracle-to-PostgreSQL migration tool."

**Step 1 — Walk through the Ora2Pg configuration:**

**Pitch:**

> "Ora2Pg reads the Oracle schema, converts every data type to its PostgreSQL equivalent, and generates a SQL script with the CREATE TABLE statements and all the INSERT rows."

**Step 2 — Export schema and data from Oracle (runs on the VM):**

1. Copy and adjust the template in `Coach/Solutions/java/ora2pg.conf`.
2. Export SQL and data:

```bash
# 1. schema
ora2pg -c ora2pg.conf -o photoalbum.sql
# 2. data
ora2pg -c ora2pg.conf -t COPY -o data.sql -u system -w photoalbum
```

**Step 3 — Import into Azure PostgreSQL:**

```bash
export PGPASSWORD="<admin-password>"
export PGUSER="psqladmin"
export PGHOST="<host>"
psql -h $PGHOST -U $PGUSER -d photoalbum <<'SQL'
CREATE ROLE photoalbum LOGIN PASSWORD 'photoalbum';
GRANT photoalbum TO psqladmin;
SQL

psql -h $PGHOST -U $PGUSER -d photoalbum < TABLE_photoalbum.sql
psql -h $PGHOST -U $PGUSER -d photoalbum < SEQUENCE_photoalbum.sql
psql -h $PGHOST -U $PGUSER -d photoalbum < data.sql
```

### Segment 5 — The Reveal **(48:00 – 55:00)**

**Pitch:**

> "Let me show you where we started — and where we are now."

**Steps:**

1. Open **Tab 1** (legacy VM app) and **Tab 3** (ACA app) side-by-side
2. On the legacy tab: `http://<vm_public_ip>:8080` — Oracle-backed app on a VM
3. On the ACA tab: `https://<app_url>` — **the same photos are already there**, migrated

**Pitch:**

> "Same application. Same photos. But everything underneath it is different.
>
> Before: Java 8 end-of-life, Spring Boot unsupported, use of Oracle, photos stored as database BLOBs, running on a virtual machine with no secrets management and no observability.
>
> After: Java 21 LTS, Spring Boot 3.x, Azure Database for PostgreSQL — fully managed, no server to patch. Azure Container Apps — serverless, autoscaling, no infrastructure to manage. Secrets locked in Key Vault, never in code. Telemetry flowing to Application Insights with zero code changes.
>
> GitHub Copilot assessed the codebase, generated the migration plan, and executed the code changes. The developer stayed in control — Copilot accelerated every step of the journey."

**Migration summary:**

| | Before | After |
|---|---|---|
| Java | 8 (end-of-life 2019) | 21 LTS |
| Spring Boot | 2.7.18 (unsupported) | 3.x |
| Database | Oracle XE in Docker | Azure Database for PostgreSQL |
| Photo storage | Oracle BLOBs | Azure Blob Storage |
| Secrets | Plaintext in config | Azure Key Vault + Managed Identity |
| Observability | None | Azure Application Insights |
| Hosting | Azure VM | Azure Container Apps |

## Troubleshooting

### Oracle container not healthy on VM

```bash
ssh azureuser@<public_ip>
sudo docker compose -f /opt/photoalbum/docker-compose.yml logs oracle-db | tail -30
# Wait until: DATABASE IS READY TO USE!
# Oracle first-time init can take up to 5 minutes
```

### `modernize` command not found

```bash
export PATH="$HOME/.local/bin:$PATH"
# Add this line to ~/.bashrc or ~/.zshrc to persist across sessions
```

### `mvn clean package` fails after migration

Check these in order:

1. **Missed `javax.*` imports** — re-run the namespace migration task from the plan, or open Copilot and ask it to fix remaining `javax.*` imports
2. **Oracle dialect still in `application.properties`** — ensure `spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect`
3. **`ojdbc8` still in `pom.xml`** — remove it and add `org.postgresql:postgresql`
4. Reference the Coach solution: `Coach/Solutions/java/PhotoAlbum-Java/`

### `psql` connection refused to Azure PostgreSQL

Your IP may not be in the firewall allowlist. Add it:

```bash
az postgres flexible-server firewall-rule create \
  --resource-group <resource_group_name> \
  --name <postgresql_server_name> \
  --rule-name "AllowMyIP" \
  --start-ip-address "$(curl -s https://api.ipify.org)" \
  --end-ip-address "$(curl -s https://api.ipify.org)"
```
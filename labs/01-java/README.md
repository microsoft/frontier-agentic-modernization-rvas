# Java – PhotoAlbum

Modernize the PhotoAlbum Spring Boot application with GitHub Copilot: Spring Boot 2.7 / Java 8 / Oracle DB to Spring Boot 3.x / Java 25 / Azure Database for PostgreSQL and Blob Storage, deployed on Azure Container Apps.

## Modules

| # | Module | Duration | What you do |
|---|--------|----------|-------------|
| [00](challenges/00-prerequisites-and-setup.md) | Prerequisites and setup | ~30 min | Install tools, verify access and initialize the legacy app |
| [01](challenges/01-assess-the-legacy-app.md) | Assess the legacy Java application | ~30 min | Run the Copilot Modernization assessment |
| [02](challenges/02-modernize-the-app.md) | Modernize the Java application | ~150 min | Move to Java 25, Spring Boot 3 and PostgreSQL |
| [03](challenges/03-containerize-and-deploy.md) | Containerize and deploy | ~60 min | Build a Docker image and deploy with Terraform to Container Apps |
| [04](challenges/04-migrate-the-database.md) | Migrate the database | ~60 min | Export with Ora2Pg and import into PostgreSQL |
| [05](challenges/05-observe-and-secure.md) | Observe and secure | ~40 min | Add Application Insights, Key Vault and Managed Identity |
| [06](challenges/06-infuse-ai.md) | Infuse AI *(stretch)* | ~75 min | Add Azure OpenAI image enrichment |

## Requirements

See the shared [prerequisites](../../README.md) and the [labs guide](../README.md) for Azure requirements. Docker with at least 4 GB RAM is needed for the Oracle XE container.

## Resources

The legacy app (`resources/PhotoAlbum-Java`, a Git submodule), the Terraform in `resources/infra/`, and the Ora2Pg template `resources/ora2pg.conf` live under [`resources/`](resources/).
The reference solution for deployment is in [`../../solutions/01-java/`](../../solutions/01-java/).

## Notes

Each module ends with a troubleshooting table. The [troubleshooting guide](../TROUBLESHOOTING.md) covers Terraform provider registration and network-policy blocks. A demo version of the migration lives in the [Java demo guide](../../demo/java/guide.md).

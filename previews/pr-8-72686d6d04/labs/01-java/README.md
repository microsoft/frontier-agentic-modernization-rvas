# Java – PhotoAlbum

Modernize the PhotoAlbum Spring Boot application with GitHub Copilot: Spring Boot 2.7 / Java 8 / Oracle DB to Spring Boot 3.x / Java 25 / Azure Database for PostgreSQL and Blob Storage, deployed on Azure Container Apps.

## Challenges

| # | Challenge | Capability |
|---|-----------|------------|
| [00](challenges/00-prerequisites-and-setup.md) | Prerequisites and Setup | Tools, access and legacy app running |
| [01](challenges/01-assess-the-legacy-app.md) | Assess the Legacy Java Application | Copilot Modernization assessment |
| [02](challenges/02-modernize-the-app.md) | Modernize the Java Application | Java 25, Spring Boot 3, PostgreSQL |
| [03](challenges/03-containerize-and-deploy.md) | Containerize and Deploy | Docker, Terraform, Container Apps |
| [04](challenges/04-migrate-the-database.md) | Migrate the Database | Ora2Pg export and PostgreSQL import |
| [05](challenges/05-observe-and-secure.md) | Observe and Secure | Application Insights, Key Vault, Managed Identity |
| [06](challenges/06-infuse-ai.md) | Infuse AI *(stretch)* | Azure OpenAI image enrichment |

## Requirements

See the shared [prerequisites](../../README.md) and the [labs guide](../README.md) for Azure requirements. Docker with at least 4 GB RAM is needed for the Oracle XE container.

## Resources

The legacy app (`resources/PhotoAlbum-Java`, a Git submodule), the Terraform in `resources/infra/`, and the Ora2Pg template `resources/ora2pg.conf` live under [`resources/`](resources/).
The reference solution for deployment is in [`../../solutions/01-java/`](../../solutions/01-java/).

## Notes

Each challenge file holds the notes inside **Hints and notes**: common pitfalls, expected findings and reflection questions. The [troubleshooting guide](../TROUBLESHOOTING.md) covers Terraform provider registration and network-policy blocks. A demo version of the migration lives in the [Java demo guide](../../demo/java/guide.md).

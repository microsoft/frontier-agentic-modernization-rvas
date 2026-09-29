[< Previous Challenge](./Challenge-03.md) — **[Home](../../README.md)** — [Next Challenge >](./Challenge-05.md)

# Challenge 04 — Migrate the PhotoAlbum Database to Azure PostgreSQL

## Introduction

The modernized PhotoAlbum runs on Spring Boot 3 / Java 25 in Azure Container Apps with Azure Database for PostgreSQL Flexible Server, Azure Key Vault, and Azure Blob Storage. However, the **production data** from the legacy application still lives in the Oracle XE database running as a Docker container. Before shutting down that container permanently, the data must be **migrated to Azure Database for PostgreSQL Flexible Server** with full fidelity.

In this challenge you can use two migration paths:

- **Path 1 (primary): Ora2Pg + psql** for deterministic offline export/import.
- **Path 2 (alternative): Oracle to Azure Database for PostgreSQL Schema and Application Conversion (Preview)** in [PostgreSQL for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-ossdata.vscode-pgsql), including AI-assisted schema and application conversion.

## Description

Perform a complete offline database migration from the legacy Oracle XE database to the Azure Database for PostgreSQL Flexible Server provisioned in Challenge 03.

**Prepare the source**

- Start the legacy Oracle stack (from `Resources/java/PhotoAlbum-Java/`) and ensure the `photoalbum` schema contains data by uploading at least 2–3 photos through the running legacy application.
- Note the photo row count — you will verify this number matches exactly after migration.

**Path 1 (Primary): Ora2Pg + psql**

Ora2Pg is an open-source Oracle-to-PostgreSQL migration tool. Research how to install it for your OS and verify it is working before proceeding.

A ready-to-use configuration template is provided at [`../Resources/java/ora2pg.conf`](../Resources/java/ora2pg.conf) — copy it, adjust the Oracle connection details to match your running container, and use it to export the schema and data as a PostgreSQL-compatible SQL script.

Once you have the export, import it into your Azure Database for PostgreSQL Flexible Server using your preferred PostgreSQL client tool. The connection details for the target database are available from the Terraform outputs you produced in Challenge 03.

**Path 2 (Alternative): VS Code PostgreSQL extension (Preview)**

If your environment supports it, the [PostgreSQL for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-ossdata.vscode-pgsql) extension provides an Oracle-to-PostgreSQL migration workflow with AI-assisted schema and application conversion.

Install the extension, connect to both your Oracle source and Azure PostgreSQL target, and follow the Schema Conversion workflow. Review all flagged items before applying changes to the target database.

> **Note:** If the Preview migration features are unavailable in your environment, use Path 1.

**Critical: protect the migrated data**

The modernized Spring Boot application has a Hibernate setting that controls what happens to the database schema on startup. The wrong value will silently **drop and recreate all tables** the first time the application starts — wiping every migrated row. Identify this setting, understand the difference between its values, and update it appropriately before redeploying the application against the populated PostgreSQL database.

**Validate**

After the import, verify that:
- The row count in the PostgreSQL `photos` table matches the Oracle source
- Image binary data was correctly converted from Oracle's format to PostgreSQL's equivalent
- The deployed PhotoAlbum application displays the migrated photos without requiring re-upload

## Success Criteria

To complete this challenge, demonstrate:

1. Migration completes successfully using either valid path.
2. The `photos` table in Azure PostgreSQL has a row count matching the Oracle source — verified by querying both databases.
3. Image data was correctly converted and is present in the PostgreSQL rows that had blobs in Oracle.
4. The deployed PhotoAlbum Container App displays the migrated photos in the gallery — no re-upload required.
5. No database passwords appear in plain text in `application.properties` or Container App environment variables — credentials come from Azure Key Vault.

## Learning Resources

- [Ora2Pg Documentation](https://github.com/darold/ora2pg)
- [Ora2Pg Installation Guide](https://ora2pg.darold.net/docs/installation)
- [Ora2Pg Configuration Reference](https://ora2pg.darold.net/docs)
- [VS Code PostgreSQL extension (`ms-ossdata.vscode-pgsql`)](https://marketplace.visualstudio.com/items?itemName=ms-ossdata.vscode-pgsql)
- [Oracle to Azure Database for PostgreSQL Flexible Server — Ora2Pg Migration Guide](https://learn.microsoft.com/azure/postgresql/migrate/oracle-migration/how-to-migrate-oracle-ora2pg)
- [Oracle to PostgreSQL data type mapping reference](https://learn.microsoft.com/azure/postgresql/migrate/how-to-migrate-from-oracle#data-types)
- [Azure Database for PostgreSQL Flexible Server overview](https://learn.microsoft.com/azure/postgresql/flexible-server/overview)
- [`psql` — PostgreSQL interactive terminal](https://www.postgresql.org/docs/current/app-psql.html)
- [Hibernate `ddl-auto` reference](https://docs.hibernate.org/orm/6.4/userguide/html_single/Hibernate_User_Guide.html#configurations-hbmddl)

## Tips

- Your Challenge 03 Terraform outputs contain the PostgreSQL Flexible Server hostname and admin credentials you need — check the `infra/` directory outputs.
- When configuring Ora2Pg, pay close attention to the Oracle DSN format, schema name, and the separator between configuration directives — these are common sources of silent failures.
- If you encounter SSL errors connecting to Azure PostgreSQL, check the Connection Security settings in the Azure Portal.
- Ora2Pg handles the Oracle `BLOB` → PostgreSQL `BYTEA` type conversion automatically — you do not need to change your JPA entity definitions.
- Hibernate has a setting that controls whether tables are created, updated, or only validated on application start. Review what each value means before redeploying the application against your freshly migrated data.


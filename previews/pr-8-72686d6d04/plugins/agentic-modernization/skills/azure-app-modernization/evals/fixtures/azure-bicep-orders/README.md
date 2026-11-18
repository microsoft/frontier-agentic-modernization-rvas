# Orders portal (already on Azure)

Node.js orders portal deployed to a single App Service in westeurope.
Infrastructure lives in `infra/` and is deployed by the platform team's pipeline.
The SQL server allows public network access because the app has no VNet integration yet.
Ops complaint: one instance, no zone redundancy, and the connection string is an app setting.

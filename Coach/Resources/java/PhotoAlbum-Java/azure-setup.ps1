#!/usr/bin/env pwsh

# Colors for output using ANSI escape codes (works in modern PowerShell)
$RED = "`e[31m"
$GREEN = "`e[32m"
$YELLOW = "`e[33m"
$NC = "`e[0m" # No Color

Write-Host "${GREEN}=== Azure Photo Album Resources Setup ===${NC}" -NoNewline
Write-Host ""

# Variables
$RANDOM_SUFFIX = -join ((1..3) | ForEach-Object { '{0:x}' -f (Get-Random -Maximum 256) })
$RESOURCE_GROUP = "photo-album-resources-${RANDOM_SUFFIX}"
$LOCATION = "westus3"
$ACR_NAME = "photoalbumacr$(Get-Random -Maximum 99999)"
$AKS_NODE_VM_SIZE = "Standard_D8ds_v5"
$POSTGRES_SERVER_NAME = "$RESOURCE_GROUP-postgresql"
$PostgreSQL_SKU = "Standard_D4ads_v5"
$POSTGRES_ADMIN_USER="photoalbum_admin"
$POSTGRES_ADMIN_PASSWORD="P@ssw0rd123!"
$POSTGRES_DATABASE_NAME="photoalbum"
$POSTGRES_APP_USER="photoalbum"
$POSTGRES_APP_PASSWORD="photoalbum"

Write-Host "${YELLOW}Using default subscription...${NC}" -NoNewline
Write-Host ""
az account show --query "{Name:name, SubscriptionId:id}" -o table

if ($LASTEXITCODE -ne 0) {
    Write-Host "${RED}Failed to get Azure account information. Please ensure you are logged in with 'az login'${NC}" -NoNewline
    Write-Host ""
    exit 1
}

# Create Resource Group
Write-Host "${YELLOW}Creating resource group: $RESOURCE_GROUP${NC}" -NoNewline
Write-Host ""
az group create `
    --name $RESOURCE_GROUP `
    --location $LOCATION

if ($LASTEXITCODE -ne 0) {
    Write-Host "${RED}Failed to create resource group${NC}" -NoNewline
    Write-Host ""
    exit 1
}

# Create Azure Container Registry
Write-Host "${YELLOW}Creating Azure Container Registry: $ACR_NAME${NC}" -NoNewline
Write-Host ""
az acr create `
    --name $ACR_NAME `
    --resource-group $RESOURCE_GROUP `
    --location $LOCATION `
    --sku Basic `
    --admin-enabled true

if ($LASTEXITCODE -ne 0) {
    Write-Host "${RED}Failed to create Azure Container Registry${NC}" -NoNewline
    Write-Host ""
    exit 1
}

# Create Azure Kubernetes Service (AKS) Cluster
Write-Host "${YELLOW}Creating AKS Cluster: ${RESOURCE_GROUP}-aks${NC}" -NoNewline
Write-Host ""
az aks create `
    --resource-group $RESOURCE_GROUP `
    --name "$RESOURCE_GROUP-aks" `
    --node-count 2 `
    --generate-ssh-keys `
    --location $LOCATION `
    --node-vm-size $AKS_NODE_VM_SIZE

if ($LASTEXITCODE -ne 0) {
    Write-Host "${RED}Failed to create AKS cluster${NC}" -NoNewline
    Write-Host ""
    exit 1
}

# Grant AKS permission to pull images from ACR
Write-Host "${YELLOW}Granting AKS permission to pull images from ACR: $ACR_NAME${NC}" -NoNewline
Write-Host ""
az aks update `
    --resource-group $RESOURCE_GROUP `
    --name "$RESOURCE_GROUP-aks" `
    --attach-acr $ACR_NAME

if ($LASTEXITCODE -ne 0) {
    Write-Host "${RED}Failed to attach ACR to AKS cluster${NC}" -NoNewline
    Write-Host ""
    exit 1
}

# Create PostgreSQL Flexible Server
Write-Host "${YELLOW}Creating PostgreSQL Flexible Server: ${POSTGRES_SERVER_NAME}${NC}" -NoNewline
Write-Host ""

az postgres flexible-server create `
    --resource-group "$RESOURCE_GROUP" `
    --name "$POSTGRES_SERVER_NAME" `
    --location "$LOCATION" `
    --admin-user "$POSTGRES_ADMIN_USER" `
    --admin-password "$POSTGRES_ADMIN_PASSWORD" `
    --version "15" `
    --sku-name $PostgreSQL_SKU `
    --storage-size "32" `
    --backup-retention "7" `
    --public-access "0.0.0.0" `

if ($LASTEXITCODE -ne 0) {
    Write-Host "${RED}Failed to create PostgreSQL Flexible Server${NC}" -NoNewline
    Write-Host ""
    exit 1
}

# Create application database
Write-Host "${YELLOW}Creating database: ${POSTGRES_DATABASE_NAME}${NC}" -NoNewline
Write-Host ""

az postgres flexible-server db create `
    --resource-group "$RESOURCE_GROUP" `
    --server-name "$POSTGRES_SERVER_NAME" `
    --database-name "$POSTGRES_DATABASE_NAME" `

if ($LASTEXITCODE -ne 0) {
    Write-Host "${RED}Failed to create PostgreSQL database${NC}" -NoNewline
    Write-Host ""
    exit 1
}

# Configure firewall for Azure services
Write-Host "${YELLOW}Configuring firewall rules...${NC}" -NoNewline
Write-Host ""
az postgres flexible-server firewall-rule create `
    --resource-group "$RESOURCE_GROUP" `
    --name "$POSTGRES_SERVER_NAME" `
    --rule-name "AllowAzureServices" `
    --start-ip-address "0.0.0.0" `
    --end-ip-address "0.0.0.0" `

if ($LASTEXITCODE -ne 0) {
    Write-Host "${RED}Failed to configure firewall rules${NC}" -NoNewline
    Write-Host ""
    exit 1
}

# Add current IP to firewall
$CURRENT_IP = (Invoke-RestMethod -Uri "https://api.ipify.org" -UseBasicParsing).Trim()
if ($CURRENT_IP) {
    Write-Host "${YELLOW}Adding your current IP ($CURRENT_IP) to firewall...${NC}" -NoNewline
    Write-Host ""
    az postgres flexible-server firewall-rule create `
        --resource-group "$RESOURCE_GROUP" `
        --name "$POSTGRES_SERVER_NAME" `
        --rule-name "AllowCurrentIP" `
        --start-ip-address "$CURRENT_IP" `
        --end-ip-address "$CURRENT_IP" `

    if ($LASTEXITCODE -ne 0) {
    Write-Host "${RED}Failed to add your current IP to firewall${NC}" -NoNewline
    Write-Host ""
    exit 1
}
}

# Get server FQDN
Write-Host "${YELLOW}Getting server connection details...${NC}" -NoNewline
Write-Host ""
$SERVER_FQDN = az postgres flexible-server show `
    --resource-group "$RESOURCE_GROUP" `
    --name "$POSTGRES_SERVER_NAME" `
    --query "fullyQualifiedDomainName" `
    --output tsv

# Wait a moment for server to be fully ready
Write-Host "${YELLOW}Waiting for server to be fully ready...${NC}" -NoNewline
Write-Host ""
Start-Sleep -Seconds 30

# Setup application user and tables
Write-Host "${YELLOW}Setting up database user and tables...${NC}" -NoNewline
Write-Host ""

# Create application user using the more reliable execute command
Write-Host "${YELLOW}Creating application user...${NC}" -NoNewline
Write-Host ""
try {
    az postgres flexible-server execute `
        --name "$POSTGRES_SERVER_NAME" `
        --admin-user "$POSTGRES_ADMIN_USER" `
        --admin-password "$POSTGRES_ADMIN_PASSWORD" `
        --database-name "postgres" `
        --querytext "CREATE USER photoalbum WITH PASSWORD 'photoalbum';"
} catch {
    Write-Host "${YELLOW}User may already exist, continuing...${NC}" -NoNewline
    Write-Host ""
}

# Grant database connection privileges
Write-Host "${YELLOW}Granting database connection privileges...${NC}" -NoNewline
Write-Host ""
try {
    az postgres flexible-server execute `
        --name "$POSTGRES_SERVER_NAME" `
        --admin-user "$POSTGRES_ADMIN_USER" `
        --admin-password "$POSTGRES_ADMIN_PASSWORD" `
        --database-name "postgres" `
        --querytext "GRANT CONNECT ON DATABASE photoalbum TO photoalbum;"
} catch {
    Write-Host "${YELLOW}Grant may have failed, continuing...${NC}" -NoNewline
    Write-Host ""
}

# Grant schema privileges on the photoalbum database
Write-Host "${YELLOW}Granting schema privileges...${NC}" -NoNewline
Write-Host ""
try {
    az postgres flexible-server execute `
        --name "$POSTGRES_SERVER_NAME" `
        --admin-user "$POSTGRES_ADMIN_USER" `
        --admin-password "$POSTGRES_ADMIN_PASSWORD" `
        --database-name "photoalbum" `
        --querytext "GRANT ALL PRIVILEGES ON SCHEMA public TO photoalbum;"
} catch {
    Write-Host "${YELLOW}Schema privileges may have failed, continuing...${NC}" -NoNewline
    Write-Host ""
}

# Grant privileges on future objects (so Hibernate can create and manage tables)
Write-Host "${YELLOW}Setting up future object privileges for Hibernate...${NC}" -NoNewline
Write-Host ""
try {
    az postgres flexible-server execute `
        --name "$POSTGRES_SERVER_NAME" `
        --admin-user "$POSTGRES_ADMIN_USER" `
        --admin-password "$POSTGRES_ADMIN_PASSWORD" `
        --database-name "photoalbum" `
        --querytext "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO photoalbum;"
} catch {
    Write-Host "${YELLOW}Default privileges may have failed, continuing...${NC}" -NoNewline
    Write-Host ""
}

Write-Host "${GREEN}Database user and schema setup completed! Hibernate will create and manage tables.${NC}" -NoNewline
Write-Host ""

# Store the datasource URL for later use
$DATASOURCE_URL = "jdbc:postgresql://${SERVER_FQDN}:5432/$POSTGRES_DATABASE_NAME"
Write-Host "${YELLOW}Datasource URL: $DATASOURCE_URL${NC}" -NoNewline
Write-Host ""

# Store PostgreSQL credentials in environment variables
Write-Host "${YELLOW}Storing PostgreSQL credentials in environment variables...${NC}" -NoNewline
Write-Host ""
$env:POSTGRES_SERVER = "${POSTGRES_SERVER_NAME}.postgres.database.azure.com"
$env:POSTGRES_USER = $POSTGRES_APP_USER
$env:POSTGRES_PASSWORD = $POSTGRES_APP_PASSWORD
$env:POSTGRES_CONNECTION_STRING = $DATASOURCE_URL

# Write environment variables to .env file
Write-Host "${YELLOW}Writing environment variables to .env file...${NC}" -NoNewline
Write-Host ""
$SCRIPT_ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path
$ENV_FILE = Join-Path $SCRIPT_ROOT ".env"

$ENV_CONTENT = @"
# Azure PostgreSQL Configuration
POSTGRES_SERVER=$env:POSTGRES_SERVER
POSTGRES_USER=$env:POSTGRES_USER
POSTGRES_PASSWORD=$env:POSTGRES_PASSWORD
POSTGRES_CONNECTION_STRING=$env:POSTGRES_CONNECTION_STRING

# Azure Resources
RESOURCE_GROUP=$RESOURCE_GROUP
ACR_NAME=$ACR_NAME
AKS_CLUSTER_NAME=$RESOURCE_GROUP-aks
LOCATION=$LOCATION
"@

$ENV_CONTENT | Out-File -FilePath $ENV_FILE -Encoding UTF8
Write-Host "${GREEN}Environment variables written to: $ENV_FILE${NC}" -NoNewline
Write-Host ""

Write-Host "${GREEN}=== Setup Complete ===${NC}" -NoNewline
Write-Host ""

# Output important information
Write-Host "${GREEN}Resources created successfully:${NC}" -NoNewline
Write-Host ""
Write-Host "Resource Group: $RESOURCE_GROUP"
Write-Host "Container Registry: $ACR_NAME"
Write-Host "AKS Cluster: $RESOURCE_GROUP-aks"
Write-Host "PostgreSQL Server: $POSTGRES_SERVER_NAME"
Write-Host "Location: $LOCATION"
Write-Host ""
Write-Host "${GREEN}PostgreSQL Connection Details (stored in environment variables and .env file):${NC}" -NoNewline
Write-Host ""
Write-Host "POSTGRES_SERVER: $env:POSTGRES_SERVER"
Write-Host "POSTGRES_USER: $env:POSTGRES_USER"
Write-Host "POSTGRES_PASSWORD: $env:POSTGRES_PASSWORD"
Write-Host "POSTGRES_CONNECTION_STRING: $env:POSTGRES_CONNECTION_STRING"
Write-Host ""
Write-Host "${GREEN}All configuration has been saved to .env file in the project root.${NC}" -NoNewline
Write-Host ""

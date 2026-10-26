targetScope = 'resourceGroup'

param location string = resourceGroup().location
param env string = 'prod'
@secure()
param sqlAdminPassword string

module plan 'br/public:avm/res/web/serverfarm:0.1.1' = {
  name: 'plan'
  params: {
    name: 'asp-orders-${env}'
    skuName: 'S1'
    skuCapacity: 1
  }
}

module site 'br/public:avm/res/web/site:0.3.0' = {
  name: 'site'
  params: {
    name: 'app-orders-${env}'
    kind: 'app,linux'
    serverFarmResourceId: plan.outputs.resourceId
    appSettingsKeyValuePairs: {
      SQL_CONNECTION: 'Server=tcp:sql-orders-${env}.database.windows.net;User ID=sqladmin;Password=${sqlAdminPassword}'
    }
  }
}

resource sql 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: 'sql-orders-${env}'
  location: location
  properties: {
    administratorLogin: 'sqladmin'
    administratorLoginPassword: sqlAdminPassword
    publicNetworkAccess: 'Enabled'
  }
}

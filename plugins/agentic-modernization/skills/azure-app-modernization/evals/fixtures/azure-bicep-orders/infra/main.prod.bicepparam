using './main.bicep'
param env = 'prod'
param sqlAdminPassword = readEnvironmentVariable('SQL_ADMIN_PASSWORD')

targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention.')
param environmentName string

@minLength(1)
@description('Primary location for all resources.')
param location string

// Optional parameters
param userAssignedIdentityName string = ''
param sqlServerName string = ''
param functionPlanName string = ''
param functionStorName string = ''
param functionAppName string = ''
param staticWebAppName string = ''

// *ServiceName is used as value for the tag (azd-service-name) azd uses to identify deployment host
param webServiceName string = 'web'
param apiServiceName string = 'api'

var abbreviations = loadJsonContent('abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = {
  'azd-env-name': environmentName
  repo: 'https://github.com/azure-samples/dab-azure-sql-quickstart'
}

// Define resource group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: environmentName
  location: location
  tags: tags
}

module identity 'app/identity.bicep' = {
  name: 'identity'
  scope: resourceGroup
  params: {
    identityName: !empty(userAssignedIdentityName)
      ? userAssignedIdentityName
      : '${abbreviations.userAssignedIdentity}-${resourceToken}'
    location: location
    tags: tags
  }
}

module storage 'app/storage.bicep' = {
  name: 'storage'
  scope: resourceGroup
  params: {
    storName: !empty(functionStorName) ? functionStorName : '${abbreviations.storageAccounts}${resourceToken}'
    location: location
    tags: tags
    managedIdentityClientId: identity.outputs.clientId
  }
}

module web 'app/web.bicep' = {
  name: 'web'
  scope: resourceGroup
  params: {
    appName: !empty(staticWebAppName) ? staticWebAppName : '${abbreviations.staticWebApps}-${resourceToken}'
    location: location
    tags: tags
    serviceTag: webServiceName
    userAssignedManagedIdentity: {
      name: identity.outputs.name
      resourceId: identity.outputs.resourceId
      clientId: identity.outputs.clientId
    }
    functionAppName: api.outputs.name
  }
}

module api 'app/api.bicep' = {
  name: 'api'
  scope: resourceGroup
  params: {
    planName: !empty(functionPlanName) ? functionPlanName : '${abbreviations.appServicePlans}-${resourceToken}'
    funcName: !empty(functionAppName) ? functionAppName : '${abbreviations.functionApps}-${resourceToken}'
    location: location
    tags: tags
    serviceTag: apiServiceName
    storageAccountName: storage.outputs.name
    userAssignedManagedIdentity: {
      resourceId: identity.outputs.resourceId
      clientId: identity.outputs.clientId
    }
  }
}

module database 'app/database.bicep' = {
  name: 'database'
  scope: resourceGroup
  params: {
    serverName: !empty(sqlServerName) ? sqlServerName : '${abbreviations.sqlServers}-${resourceToken}'
    databaseName: 'adventureworkslt'
    location: location
    tags: tags
    databaseAdministrator: {
      name: identity.outputs.name
      clientId: identity.outputs.clientId
      tenantId: identity.outputs.tenantId
    }
  }
}

// Application outputs
output AZURE_STATIC_WEB_APP_ENDPOINT string = web.outputs.endpoint
output AZURE_FUNCTION_API_ENDPOINT string = api.outputs.endpoint
output AZURE_SQL_SERVER_ENDPOINT string = database.outputs.serverEndpoint

metadata description = 'Create API application resources.'

param planName string
param funcName string

param serviceTag string
param location string = resourceGroup().location
param tags object = {}

@description('The name of the storage account to use for the function app.')
param storageAccountName string

type managedIdentity = {
  resourceId: string
  clientId: string
}

@description('Unique identifier for user-assigned managed identity.')
param userAssignedManagedIdentity managedIdentity

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: storageAccountName
}

module plan '../core/host/app-service/plan.bicep' = {
  name: 'function-app-plan'
  params: {
    name: planName
    location: location
    tags: tags
    kind: 'linux'
    sku: 'B1'
    tier: 'Basic'
  }
}

module func '../core/host/app-service/site.bicep' = {
  name: 'function-app-site'
  params: {
    name: funcName
    location: location
    tags: union(
      tags,
      {
        'azd-service-name': serviceTag
      }
    )
    enableSystemAssignedManagedIdentity: false
    userAssignedManagedIdentityIds: [
      userAssignedManagedIdentity.resourceId
    ]
    alwaysOn: true
    parentPlanName: plan.outputs.name
    kind: 'functionapp,linux'
    runtimeName: 'dotnet-isolated'
    runtimeVersion: '8.0'
  }
}

module config '../core/host/app-service/config-appsettings.bicep' = {
  name: 'function-app-config-app-settings'
  params: {
    parentSiteName: func.outputs.name
    appSettings: {
      AzureWebJobsStorage__accountName: storageAccount.name
      AzureWebJobsStorage__credential: 'managedidentity'
      AzureWebJobsStorage__clientId: userAssignedManagedIdentity.clientId
      SCM_DO_BUILD_DURING_DEPLOYMENT: false
      ENABLE_ORYX_BUILD: true
      FUNCTIONS_EXTENSION_VERSION: '~4'
      FUNCTIONS_WORKER_RUNTIME: 'dotnet-isolated'
    }
  }
}

output name string = func.outputs.name
output endpoint string = func.outputs.endpoint

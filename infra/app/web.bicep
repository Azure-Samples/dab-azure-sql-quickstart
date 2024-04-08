metadata description = 'Create web application resources.'

param appName string

param serviceTag string
param location string = resourceGroup().location
param tags object = {}

type managedIdentity = {
  name: string
  resourceId: string
  clientId: string
}

@description('Unique identifier for user-assigned managed identity.')
param userAssignedManagedIdentity managedIdentity

@description('Name of the linked backend Azure Functions app.')
param functionAppName string

module web '../core/host/static-web-app/app.bicep' = {
  name: 'static-web-app'
  params: {
    name: appName
    location: location
    tags: union(
      tags,
      {
        'azd-service-name': serviceTag
      }
    )
    sku: 'Standard'
    enableSystemAssignedManagedIdentity: false
    userAssignedManagedIdentityIds: [
      userAssignedManagedIdentity.resourceId
    ]
  }
}

module backend '../core/host/static-web-app/backend.bicep' = {
  name: 'static-web-app-backend'
  params: {
    parentSiteName: web.outputs.name
    functionAppName: functionAppName
  }
}

output name string = web.outputs.name
output endpoint string = web.outputs.uri

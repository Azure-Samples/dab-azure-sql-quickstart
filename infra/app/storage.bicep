metadata description = 'Create storage resources.'

param storName string

param location string = resourceGroup().location
param tags object = {}

@description('Unique identifier for user-assigned managed identity.')
param managedIdentityClientId string

module storage '../core/storage/account.bicep' = {
  name: 'function-app-storage'
  params: {
    name: storName
    location: location
    tags: tags
    httpsOnly: true
    publicBlobAccess: false
    allowSharedKeyAccess: false
    defaultToEntraAuthentication: true
    allowPublicNetworkAccess: true
  }
}

module userAssignedManagedIdentityAssignment '../core/security/role/assignment.bicep' = {
  name: 'storage-role-assignment-blob-data-owner'
  params: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      'b7e6dc6d-f1e8-4753-8033-0f276bb0955b' // Storage Blob Data Owner built-in role
    )
    principalId: managedIdentityClientId // Principal to assign role
    principalType: 'ServicePrincipal' // Application user
  }
}

output name string = storage.outputs.name

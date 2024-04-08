metadata description = 'Creates an Azure Static Web Apps instance.'

param name string
param location string = resourceGroup().location
param tags object = {}

@allowed([
  'Free'
  'Standard'
])
param sku string = 'Free'

@description('Enable system-assigned managed identity. Defaults to false.')
param enableSystemAssignedManagedIdentity bool = false

@description('List of user-assigned managed identities. Defaults to an empty list.')
param userAssignedManagedIdentityIds string[] = []

resource web 'Microsoft.Web/staticSites@2022-09-01' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: enableSystemAssignedManagedIdentity
      ? !empty(userAssignedManagedIdentityIds) ? 'SystemAssigned, UserAssigned' : 'SystemAssigned'
      : !empty(userAssignedManagedIdentityIds) ? 'UserAssigned' : 'None'
    userAssignedIdentities: !empty(userAssignedManagedIdentityIds)
      ? toObject(userAssignedManagedIdentityIds, uaid => uaid, uaid => {})
      : null
  }
  sku: {
    name: sku
    tier: sku
  }
  properties: {
    provider: 'Custom'
  }
}

output name string = web.name
output uri string = 'https://${web.properties.defaultHostname}'

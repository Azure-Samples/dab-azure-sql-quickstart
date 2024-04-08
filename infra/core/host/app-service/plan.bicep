metadata description = 'Creates an Azure App Service plan.'

param name string
param location string = resourceGroup().location
param tags object = {}

@allowed([
  'linux'
])
@description('OS type of the plan. Defaults to "linux".')
param kind string = 'linux'

@allowed([
  'F1'
  'D1'
  'B1'
  'Y1'
])
@description('SKU for the plan. Defaults to "F1".')
param sku string = 'F1'

@allowed([
  'Free'
  'Shared'
  'Basic'
  'Standard'
  'Premium'
  'Dynamic'
])
@description('Tier for the plan. Defaults to "Free".')
param tier string = 'Free'

resource plan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
    tier: tier
  }
  kind: kind
  properties: {
    reserved: kind == 'linux' ? true : null
  }
}

output name string = plan.name

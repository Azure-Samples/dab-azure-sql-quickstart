metadata description = 'Creates an Azure Static Web Apps instance.'

param name string
param location string = resourceGroup().location
param tags object = {}

@allowed([
  'Free'
  'Standard'
])
param sku string = 'Free'

resource web 'Microsoft.Web/staticSites@2022-09-01' = {
  name: name
  location: location
  tags: tags
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

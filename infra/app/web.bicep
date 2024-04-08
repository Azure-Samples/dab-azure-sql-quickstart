metadata description = 'Create web application resources.'

param appName string

param serviceTag string
param location string = resourceGroup().location
param tags object = {}

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
  }
}

output name string = web.outputs.name
output endpoint string = web.outputs.uri

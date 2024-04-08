metadata description = 'Create an Azure SQL database.'

param name string
param location string = resourceGroup().location
param tags object = {}

@description('Name of the parent Azure SQL server.')
param parentServerName string

@description('If true, the sample database will be deployed. Defaults to false.')
param deploySample bool = false

@allowed([
  'AdventureWorksLT'
  'WideWorldImportersFull'
  'WideWorldImportersStd'
])
@description('Name of the sample database to create. Defaults to "AdventureWorksLT".')
param sample string = 'AdventureWorksLT'

resource server 'Microsoft.Sql/servers@2023-08-01-preview' existing = {
  name: parentServerName
}

@allowed([
  'Standard'
])
@description('SKU for the plan. Defaults to "Standard."')
param sku string = 'Standard'

@allowed([
  'Standard'
])
@description('Tier for the plan. Defaults to "Standard."')
param tier string = 'Standard'

resource database 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
  name: name
  parent: server
  location: location
  tags: tags
  sku: {
    name: sku
    tier: tier
  }
  properties: {
    sampleName: deploySample ? sample : null
  }
}

output name string = database.name

metadata description = 'Create database resources.'

param serverName string
param databaseName string

param location string = resourceGroup().location
param tags object = {}

type databasePrincipal = {
  name: string
  clientId: string
  tenantId: string
}

@description('Principal to assign administrator access.')
param databaseAdministrator databasePrincipal

module server '../core/database/sql/server.bicep' = {
  name: 'sql-server'
  params: {
    name: serverName
    location: location
    tags: tags
    enablePublicNetworkAccess: true
    adminLogin: databaseAdministrator.name
    adminType: 'Application'
    adminSid: databaseAdministrator.clientId
    adminTenantId: databaseAdministrator.tenantId
  }
}

module firewallRules '../core/database/sql/firewall-rules.bicep' = {
  name: 'sql-firewall-rules'
  params: {
    name: 'AllowAllAzureInternal'
    parentServerName: server.outputs.name
    startIpAddress: '0.0.0.0' // "0.0.0.0" for all Azure-internal IP addresses.
    endIpAddress: '0.0.0.0' // "0.0.0.0" for all Azure-internal IP addresses.
  }
}

module database '../core/database/sql/database.bicep' = {
  name: 'sql-database'
  params: {
    name: databaseName
    parentServerName: server.outputs.name
    location: location
    tags: tags
    deploySample: true
    sample: 'AdventureWorksLT'
    sku: 'Standard'
    tier: 'Standard'
  }
}

output serverName string = server.outputs.name
output serverEndpoint string = server.outputs.endpoint
output databaseName string = database.outputs.name

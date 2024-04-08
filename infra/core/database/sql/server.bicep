metadata description = 'Creates an Azure SQL server. Only Microsoft Entra ID authentication is supported.'

param name string
param location string = resourceGroup().location
param tags object = {}

@description('Name of the principal to assign administrator access.')
param adminLogin string

@allowed([
  'User'
  'Group'
  'Application'
])
@description('Type of the principal to assign administrator access. Defaults to "User."')
param adminType string = 'User'

@description('ObjectId of the principal to assign administrator access.')
param adminSid string

@description('TenantId of the principal to assign administrator access.')
param adminTenantId string

resource server 'Microsoft.Sql/servers@2023-08-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: {
    administrators: {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: true
      login: adminLogin
      principalType: adminType
      sid: adminSid
      tenantId: adminTenantId
    }
  }
}

output name string = server.name
output endpoint string = server.properties.fullyQualifiedDomainName

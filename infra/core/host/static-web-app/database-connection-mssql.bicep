metadata description = 'Creates an Azure App Service database connection.'

@description('Name of the parent static web site for this connection.')
param parentSiteName string

@description('Name of the Azure SQL server for this connection.')
param serverName string

@description('Name of the Azure SQL database for this connection.')
param databaseName string

@description('Name of the user-assigned managed identity for this connection.')
param identityName string

resource site 'Microsoft.Web/staticSites@2022-09-01' existing = {
  name: parentSiteName
}

resource server 'Microsoft.Sql/servers@2023-08-01-preview' existing = {
  name: serverName
}

resource database 'Microsoft.Sql/servers/databases@2023-08-01-preview' existing = {
  name: databaseName
}

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: identityName
}

resource backend 'Microsoft.Web/staticSites/databaseConnections@2022-09-01' = {
  name: 'static-web-app-database-connection'
  parent: site
  properties: {
    connectionIdentity: identity.id
    connectionString: 'Server=tcp:${server.properties.fullyQualifiedDomainName},1433;Initial Catalog=${database.name};Authentication=Active Directory Managed Identity;Encrypt=True;'
    region: database.location
    resourceId: database.id
  }
}

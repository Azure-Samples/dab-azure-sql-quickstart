metadata description = 'Creates an Azure App Service backend resource.'

@description('Name of the parent static web site for this backend.')
param parentSiteName string

@description('Name of the Azure Functions backend resource.')
param functionAppName string

resource site 'Microsoft.Web/staticSites@2022-09-01' existing = {
  name: parentSiteName
}

resource func 'Microsoft.Web/sites@2022-09-01' existing = {
  name: functionAppName
}

resource backend 'Microsoft.Web/staticSites/linkedBackends@2022-09-01' = {
  name: 'static-web-app-backend'
  parent: site
  properties: {
    backendResourceId: func.id
    region: func.location
  }
}

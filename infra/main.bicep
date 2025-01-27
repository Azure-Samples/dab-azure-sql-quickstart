metadata description = 'Provisions resources for a web application that uses Azure SDK for Go to connect to Azure SQL database.'

targetScope = 'resourceGroup'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention.')
param environmentName string

@minLength(1)
@description('Primary location for all resources.')
param location string

@description('Id of the principal to assign database and application roles.')
param deploymentUserPrincipalId string = ''

// serviceName is used as value for the tag (azd-service-name) azd uses to identify deployment host
param apiServiceName string = 'api'
param webServiceName string = 'web'

var resourceToken = toLower(uniqueString(resourceGroup().id, environmentName, location))
var tags = {
  'azd-env-name': environmentName
  repo: 'https://github.com/azure-samples/dab-azure-sql-quickstart'
}

module managedIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.0' = {
  name: 'user-assigned-identity'
  params: {
    name: 'managed-identity-${resourceToken}'
    location: location
    tags: tags
  }
}

module server 'br/public:avm/res/sql/server:0.12.0' = {
  name: 'sql-server'
  params: {
    name: 'sql-server-${resourceToken}'
    location: location
    tags: tags
    publicNetworkAccess: 'Enabled'
    administrators: {
      azureADOnlyAuthentication: true
      login: managedIdentity.outputs.name
      principalType: 'Application'
      sid: managedIdentity.outputs.clientId
      tenantId: tenant().tenantId
    }    
    firewallRules: [
      {
        name: 'AllowAllAzureInternal'
        startIpAddress: '0.0.0.0'
        endIpAddress: '0.0.0.0'
      }
    ]
    databases: [
      {
        name: 'adventureworkslt'
        sku: {
          name: 'Standard'
          tier: 'Standard'
        }
        sampleName: 'AdventureWorksLT'
        maxSizeBytes: 268435456000
        zoneRedundant: false
      }
    ]
  }
}

module containerRegistry 'br/public:avm/res/container-registry/registry:0.7.0' = {
  name: 'container-registry'
  params: {
    name: 'containerreg${resourceToken}'
    location: location
    tags: tags
    acrAdminUserEnabled: false
    anonymousPullEnabled: true
    publicNetworkAccess: 'Enabled'
    acrSku: 'Standard'
  }
}

var containerRegistryRole = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '8311e382-0749-4cb8-b61a-304f252e45ec'
) // AcrPush built-in role

module registryUserAssignment 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.1' = if (!empty(deploymentUserPrincipalId)) {
  name: 'container-registry-role-assignment-push-user'
  params: {
    principalId: deploymentUserPrincipalId
    resourceId: containerRegistry.outputs.resourceId
    roleDefinitionId: containerRegistryRole
  }
}

module logAnalyticsWorkspace 'br/public:avm/res/operational-insights/workspace:0.7.0' = {
  name: 'log-analytics-workspace'
  params: {
    name: 'log-analytics-${resourceToken}'
    location: location
    tags: tags
  }
}

module containerAppsEnvironment 'br/public:avm/res/app/managed-environment:0.8.0' = {
  name: 'container-apps-env'
  params: {
    name: 'container-env-${resourceToken}'
    location: location
    tags: tags
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
    zoneRedundant: false
  }
}

module containerAppsApiApp 'br/public:avm/res/app/container-app:0.12.0' = {
  name: 'container-apps-app-api'
  params: {
    name: 'container-app-api-${resourceToken}'
    environmentResourceId: containerAppsEnvironment.outputs.resourceId
    location: location
    tags: union(tags, { 'azd-service-name': apiServiceName })
    ingressTargetPort: 5000
    ingressExternal: true
    ingressTransport: 'auto'
    stickySessionsAffinity: 'sticky'
    scaleMaxReplicas: 1
    scaleMinReplicas: 1
    corsPolicy: {
      allowCredentials: true
      allowedOrigins: [
        '*'
      ]
    }
    managedIdentities: {
      systemAssigned: false
      userAssignedResourceIds: [
        managedIdentity.outputs.resourceId
      ]
    }
    secrets: {
      secureList: [
        {
          name: 'azure-sql-connection-string'
          value: 'Server=tcp:${server.outputs.fullyQualifiedDomainName},1433;Initial Catalog=AdventureWorksLT;Authentication=Active Directory Default;'
        }
        {
          name: 'user-assigned-managed-identity-client-id'
          value: managedIdentity.outputs.clientId
        }
      ]
    }
    containers: [
      {
        image: 'mcr.microsoft.com/azure-databases/data-api-builder:latest'
        name: 'api-back-end'
        resources: {
          cpu: '0.25'
          memory: '.5Gi'
        }
        env: [
          {
            name: 'AZURE_SQL_CONNECTION_STRING'
            secretRef: 'azure-sql-connection-string'
          }
          {
            name: 'AZURE_CLIENT_ID'
            secretRef: 'user-assigned-managed-identity-client-id'
          }
        ]
      }
    ]
  }
}

module containerAppsWebApp 'br/public:avm/res/app/container-app:0.12.0' = {
  name: 'container-apps-app-web'
  params: {
    name: 'container-app-web-${resourceToken}'
    environmentResourceId: containerAppsEnvironment.outputs.resourceId
    location: location
    tags: union(tags, { 'azd-service-name': webServiceName })
    ingressTargetPort: 8080
    ingressExternal: true
    ingressTransport: 'auto'
    stickySessionsAffinity: 'sticky'
    scaleMaxReplicas: 1
    scaleMinReplicas: 1
    corsPolicy: {
      allowCredentials: true
      allowedOrigins: [
        '*'
      ]
    }
    managedIdentities: {
      systemAssigned: false
      userAssignedResourceIds: [
        managedIdentity.outputs.resourceId
      ]
    }
    secrets: {
      secureList: [
        {
          name: 'data-api-builder-endpoint'
          value: 'http://${containerAppsApiApp.outputs.fqdn}/graphql'
        }
      ]
    }
    containers: [
      {
        image: 'mcr.microsoft.com/azure-databases/data-api-builder:latest'
        name: 'web-front-end'
        resources: {
          cpu: '0.25'
          memory: '.5Gi'
        }
        env: [
          {
            name: 'CONFIGURATION__DATAAPIBUILDER__BASEAPIURL'
            secretRef: 'data-api-builder-endpoint'
          }
        ]
      }
    ]
  }
}

// Azure Container Apps outputs
output AZURE_CONTAINER_APPS_API_ENDPOINT string = containerAppsApiApp.outputs.fqdn
output AZURE_CONTAINER_APPS_WEB_ENDPOINT string = containerAppsWebApp.outputs.fqdn

// Azure Container Registry outputs
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerRegistry.outputs.loginServer

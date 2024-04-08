metadata description = 'Creates firewall rules for an Azure SQL server.'

param name string

@description('Name of the parent Azure SQL server.')
param parentServerName string

@description('The start IP address of the firewall rule. Must be IPv4 format.')
param startIpAddress string

@description('The end IP address of the firewall rule. Must be IPv4 format. Must be greater than or equal to startIpAddress.')
param endIpAddress string

resource server 'Microsoft.Sql/servers@2023-08-01-preview' existing = {
  name: parentServerName
}

resource rule 'Microsoft.Sql/servers/firewallRules@2023-08-01-preview' = {
  name: name
  parent: server
  properties: {
    startIpAddress: startIpAddress
    endIpAddress: endIpAddress
  }
}

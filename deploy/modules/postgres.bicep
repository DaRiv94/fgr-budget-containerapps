param administratorLogin string

@secure()
param administratorLoginPassword string
param location string = resourceGroup().location
param psqlserverName string
param serverEdition string = 'Burstable'
param skuSizeGB int = 128
param dbInstanceType string = 'Standard_B2s'
param availabilityZone string = '1'
param version string = '12'
param virtualNetworkExternalId string = ''
param subnetName string = ''
param privateDnsZoneArmResourceId string = ''

resource psqlserverName_resource 'Microsoft.DBforPostgreSQL/flexibleServers@2021-06-01' = {
  name: psqlserverName
  location: location
  sku: {
    name: dbInstanceType
    tier: serverEdition
  }
  properties: {
    version: version
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    network: {
      delegatedSubnetResourceId: (empty(virtualNetworkExternalId) ? json('null') : json('${virtualNetworkExternalId}/subnets/${subnetName}'))
      privateDnsZoneArmResourceId: (empty(virtualNetworkExternalId) ? json('null') : privateDnsZoneArmResourceId)
    }
    storage: {
      storageSizeGB: skuSizeGB
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    availabilityZone: availabilityZone
  }
}


resource psqlfirewall 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2021-06-01' = {
  name: 'AllowAllAzureSericesIps'
  parent: psqlserverName_resource
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// resource psqlbudgetdb_resource 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2021-06-01' = {
//   name: 'psqlbudgetdb'
//   parent: psqlserverName_resource
// }
// resource psqlbudgetdb_resource 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2021-06-01' = {
//   name: 'psqlbudgetdb'
//   parent: psqlserverName_resource
//   properties: {
//     charset: 'string'
//     collation: 'string'
//   }
// }
//postgres://adminusername:budpassword123!@fgrbudgetappacadb.postgres.database.azure.com:5432/postgres
//postgres://postgresuser:postgrespassword@postgresserver.postgres.database.azure.com:5432/psqlbudgetdb
//postgres://${administratorLogin}:${administratorLoginPassword}@${psqlserverName}.postgres.database.azure.com:5432/${psqlbudgetdb_resource.name}

// Create Postgres DB
// Azure Database for PostgreSQL
// Flexible server
// admin un:adminusername
// pw:budpassword123!

// Open network to Azure resources and firwall range totally open (Not reccommended)

// cost
// Standard_B2s (2 vCores) -about $50/month
// Storage selected 128 GiB - about $15/month
// General cost is $65/month

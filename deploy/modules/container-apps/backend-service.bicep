param backendServiceName string
param containerAppsEnvName string
param webhookServiceName string
param dynamicAuthServiceName string
param location string
param psqlserverName string
param adminUser string
param adminPassword string
param PLAID_DEV_CLIENT_ID string
param SANDBOX_PLAID_SECRET string
param PLAID_DEV_SECRET string
param containerAppsEnvModuleDefaultDomain string



resource cappsEnv 'Microsoft.App/managedEnvironments@2022-01-01-preview' existing = {
  name: containerAppsEnvName
}

resource webhookService 'Microsoft.App/containerApps@2022-01-01-preview' existing = {
  name: webhookServiceName
}
resource dynamicAuthService 'Microsoft.App/containerApps@2022-01-01-preview' existing = {
  name: dynamicAuthServiceName
}

resource backendService 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: backendServiceName
  location: location
  properties: {
    managedEnvironmentId: cappsEnv.id
    template: {
      containers: [
        {
          name: 'backend-service'
          image: 'dariv94/kubebud_backend:1.2.1'
          env: [
            {
              name: 'DATABASE_URL'
              secretRef: 'az-postgres-db-connection-string'
            }
            {
              name: 'PLAID_DEV_CLIENT_ID'
              secretRef: 'plaid-dev-client-id'
            }
            {
              name: 'SANDBOX_PLAID_SECRET'
              secretRef: 'sandbox-plaid-secret'
            }
            {
              name: 'PLAID_DEV_SECRET'
              secretRef: 'plaid-dev-secret'
            }
            {
              name: 'NODE_ENV'
              value: 'sandbox'
            }
            {
              name: 'FGR_BUDGET_WEBHOOK_URL'
              value: 'https://${webhookServiceName}.internal.${containerAppsEnvModuleDefaultDomain}'
            }
            {
              name: 'FGR_BUDGET_AUTH_URL'
              value: 'https://${dynamicAuthServiceName}.internal.${containerAppsEnvModuleDefaultDomain}'
            }
          ]
          probes: [
            {
              type: 'liveness'
              httpGet: {
                path: '/healthy'
                port: 4500
              }
              initialDelaySeconds: 30
              timeoutSeconds: 30
              successThreshold: 1
              failureThreshold: 10
              periodSeconds: 20
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
      }
    }
    configuration: {

      ingress: {
        external: false
        targetPort: 4500
      }
      secrets: [
        {
          name: 'az-postgres-db-connection-string'
          value: 'postgres://${adminUser}:${adminPassword}@${psqlserverName}.postgres.database.azure.com:5432/postgres?sslmode=require'
        }
        {
          name: 'plaid-dev-client-id'
          value: PLAID_DEV_CLIENT_ID
        }
        {
          name: 'sandbox-plaid-secret'
          value: SANDBOX_PLAID_SECRET
        }
        {
          name: 'plaid-dev-secret'
          value: PLAID_DEV_SECRET
        }
      ]
    }
  }
}

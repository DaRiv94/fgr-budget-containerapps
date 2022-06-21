param emailServiceName string
param containerAppsEnvModuleDefaultDomain string
param webhookServiceName string

param containerAppsEnvName string
param location string
param psqlserverName string
param adminUser string
param adminPassword string
param PLAID_DEV_CLIENT_ID string
param SANDBOX_PLAID_SECRET string
param PLAID_DEV_SECRET string


resource cappsEnv 'Microsoft.App/managedEnvironments@2022-01-01-preview' existing = {
  name: containerAppsEnvName
}

resource emailService 'Microsoft.App/containerApps@2022-01-01-preview' existing = {
  name: emailServiceName
}

resource webhookService 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: webhookServiceName
  location: location
  properties: {
    managedEnvironmentId: cappsEnv.id
    template: {
      containers: [
        {
          name: 'webhook-service'
          image: 'dariv94/kubebud_webhook:1.2.1'
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
              name: 'EMAIL_SERVICE_URL'
              value: 'https://${emailServiceName}.internal.${containerAppsEnvModuleDefaultDomain}'
            }
            {
              name: 'TO_EMAIL'
              value: 'dariv94@gmail.com'
            }
          ]
          probes: [
            {
              type: 'liveness'
              httpGet: {
                path: '/healthy'
                port: 3500
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
        targetPort: 3500
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

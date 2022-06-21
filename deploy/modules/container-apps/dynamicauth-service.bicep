param containerAppsEnvName string
param dynamicAuthServiceName string
param location string
param FGRCONFIG string


resource cappsEnv 'Microsoft.App/managedEnvironments@2022-01-01-preview' existing = {
  name: containerAppsEnvName
}

resource dynamicauthService 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: dynamicAuthServiceName
  location: location
  properties: {
    managedEnvironmentId: cappsEnv.id
    template: {
      containers: [
        {
          name: 'dynamicauth-service'
          image: 'dariv94/fgrauthservice:2.1.0'
          env: [
            {
              name: 'FGRCONFIG'
              secretRef: 'fgrconfig'
            }
            {
              name: 'NODE_ENV'
              value: 'development'
            }
          ]
          probes: [
            {
              type: 'liveness'
              httpGet: {
                path: '/healthy'
                port: 4000
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
        targetPort: 4000
      }
      secrets: [
        {
          name: 'fgrconfig'
          value: FGRCONFIG
        }
      ]
    }
  }
}

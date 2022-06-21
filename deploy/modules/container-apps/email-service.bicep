param emailServiceName string
param containerAppsEnvName string
param location string
param SENDGRID_API_KEY string
param EMAIL_VERIFICATION_SECRET string
param SEND_EMAIL string




resource cappsEnv 'Microsoft.App/managedEnvironments@2022-01-01-preview' existing = {
  name: containerAppsEnvName
}


resource emailService 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: emailServiceName
  location: location
  properties: {
    managedEnvironmentId: cappsEnv.id
    template: {
      containers: [
        {
          name: 'email-service'
          image: 'dariv94/kubebud_email_service:1.1.0'
          env: [
            {
              name: 'SENDGRID_API_KEY'
              secretRef: 'sendgrid-api-key'
            }
            {
              name: 'EMAIL_VERIFICATION_SECRET'
              secretRef: 'email-verification-secret'
            }
            {
              name: 'SEND_EMAIL'
              secretRef: 'send-email-secret'
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
        targetPort: 5500
      }
      secrets: [
        {
          name: 'sendgrid-api-key'
          value: SENDGRID_API_KEY
        }
        {
          name: 'email-verification-secret'
          value: EMAIL_VERIFICATION_SECRET
        }
        {
          name: 'send-email-secret'
          value: SEND_EMAIL
        }
      ]
    }
  }
}

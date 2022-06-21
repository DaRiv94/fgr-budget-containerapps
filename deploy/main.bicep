param location string = resourceGroup().location
param uniqueSeed string = '${subscription().subscriptionId}-${resourceGroup().name}'
param uniqueSuffix string = 'fgr-${uniqueString(uniqueSeed)}'
param containerAppsEnvName string = 'cae-${uniqueSuffix}'
param logAnalyticsWorkspaceName string = 'log-${uniqueSuffix}'
param appInsightsName string = 'appi-${uniqueSuffix}'
param webhookServiceName string = 'webh-${uniqueSuffix}'
param backendServiceName string = 'back-${uniqueSuffix}'
param dynamicAuthServiceName string = 'dynamicauth-${uniqueSuffix}'
param emailServiceName string = 'email-${uniqueSuffix}'
param psqlserverName string = 'psql${uniqueSuffix}'
param adminUser string = 'psqlusername'
param SEND_EMAIL string = 'false'

//postgresql admin password
@secure()
param adminPassword string = ''

//See Plaid Docs for more info on the following parameters https://plaid.com/ 
@secure()
param PLAID_DEV_CLIENT_ID string = ''
@secure()
param SANDBOX_PLAID_SECRET string = ''
@secure()
param PLAID_DEV_SECRET string = ''

//See https://github.com/DaRiv94/fgr_dynamic_auth for configuring Authentication and Authorization
@secure()
param FGRCONFIG string = ''

//See https://sendgrid.com/ documentation for more info on the following parameter
@secure()
param SENDGRID_API_KEY string = ''

//custom secret used for email verification - for more info see https://github.com/DaRiv94/fgr_budget_email_service
@secure()
param EMAIL_VERIFICATION_SECRET string = ''





module containerAppsEnvModule 'modules/capps-env.bicep' = {
  name: '${deployment().name}--containerAppsEnv'
  params: {
    location: location
    containerAppsEnvName: containerAppsEnvName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    appInsightsName: appInsightsName
  }
}

module postgresModule 'modules/postgres.bicep' = {
  name: '${deployment().name}--postgres'
  params: {
    psqlserverName: psqlserverName
    administratorLogin: adminUser
    administratorLoginPassword: adminPassword
    location: location
  }
}

//I should Create a bootstrap containcer to populate db with  tables




module emailServiceModule 'modules/container-apps/email-service.bicep' = {
  name: '${deployment().name}--email-service'
  dependsOn: [
    containerAppsEnvModule
  ]
  params: {
    emailServiceName: emailServiceName
    location: location
    containerAppsEnvName: containerAppsEnvName
    SENDGRID_API_KEY: SENDGRID_API_KEY
    EMAIL_VERIFICATION_SECRET: EMAIL_VERIFICATION_SECRET
    SEND_EMAIL: SEND_EMAIL
  }
}

module webhookServiceModule 'modules/container-apps/webhook-service.bicep' = {
  name: '${deployment().name}--webhook-service'
  dependsOn: [
    containerAppsEnvModule
    postgresModule
    emailServiceModule
  ]
  params: {
    emailServiceName: emailServiceName
    containerAppsEnvModuleDefaultDomain: containerAppsEnvModule.outputs.defaultDomain
    webhookServiceName: webhookServiceName
    location: location
    containerAppsEnvName: containerAppsEnvName
    psqlserverName: psqlserverName
    adminUser: adminUser    
    adminPassword: adminPassword
    PLAID_DEV_CLIENT_ID: PLAID_DEV_CLIENT_ID
    SANDBOX_PLAID_SECRET: SANDBOX_PLAID_SECRET
    PLAID_DEV_SECRET: PLAID_DEV_SECRET
  }
}



module dynamicauthServiceModule 'modules/container-apps/dynamicauth-service.bicep' = {
  name: '${deployment().name}--dynamicauth-service'
  dependsOn: [
    containerAppsEnvModule
    postgresModule
  ]
  params: {
    dynamicAuthServiceName: dynamicAuthServiceName
    location: location
    containerAppsEnvName: containerAppsEnvName
    FGRCONFIG: FGRCONFIG
  }
}

module backendServiceModule 'modules/container-apps/backend-service.bicep' = {
  name: '${deployment().name}--backend-service'
  dependsOn: [
    containerAppsEnvModule
    postgresModule
    dynamicauthServiceModule
    webhookServiceModule
  ]
  params: {
    backendServiceName: backendServiceName
    webhookServiceName: webhookServiceName
    dynamicAuthServiceName: dynamicAuthServiceName
    containerAppsEnvModuleDefaultDomain: containerAppsEnvModule.outputs.defaultDomain
    location: location
    containerAppsEnvName: containerAppsEnvName
    psqlserverName: psqlserverName
    adminUser: adminUser    
    adminPassword: adminPassword
    PLAID_DEV_CLIENT_ID: PLAID_DEV_CLIENT_ID
    SANDBOX_PLAID_SECRET: SANDBOX_PLAID_SECRET
    PLAID_DEV_SECRET: PLAID_DEV_SECRET
    
  }
}


output frontendparams array = [
  'https://${backendServiceName}.internal.${containerAppsEnvModule.outputs.defaultDomain}'
  '${containerAppsEnvName}'
  '${resourceGroup().name}'
]

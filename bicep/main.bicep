param location string = resourceGroup().location
param envName string = 'blog-sample'



param registryUsername string
@secure()
param registryPassword string

module law 'law.bicep' = {
    name: 'log-analytics-workspace'
    params: {
      location: location
      name: 'law-${envName}'
    }
}

module containerAppEnvironment 'environment.bicep' = {
  name: 'container-app-environment'
  params: {
    name: envName
    location: location
    lawClientId:law.outputs.clientId
    lawClientSecret: law.outputs.clientSecret
  }
}

module containerApp_Ml_Frontend 'containerapp.bicep' = {
  name: 'container-app-ml-frontend'
  params: {
    name: 'container-app-ml-frontend'
    location: location
    containerAppEnvironmentId: containerAppEnvironment.outputs.id
    containerImage: 'anyidea/ml-frontend:master-thesis'
    containerPort: 80 
    registry: 'index.docker.io'
    registryUsername: registryUsername
    registryPassword: registryPassword 
    envVars: [{name:'PROFILE',value: 'stage'},{name:'ML_PRIORITIZER_URL',value: containerApp_Ml_Prioritizer.outputs.fqdn}]
  }
}

module containerApp_Ml_Prioritizer 'containerapp.bicep' = {
  name: 'container-app-ml-prioritizer'
  params: {
    name: 'container-app-ml-prioritizer'
    location: location
    containerAppEnvironmentId: containerAppEnvironment.outputs.id
    containerImage: 'anyidea/ml-prioritizer:master-thesis'
    containerPort: 5000 
    registry: 'index.docker.io'
    registryUsername: registryUsername
    registryPassword: registryPassword 
    envVars: [{name:'PROFILE',value: 'stage'},{name:'MONGODB_URL',value: 'MONGODB_URL'}]
  }
}


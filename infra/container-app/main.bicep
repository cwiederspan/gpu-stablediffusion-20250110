param location string = resourceGroup().location
param baseName string = 'cdw-gpuapp-20250110'
param workloadProfileName string = 'gpu-serverless'

param userManagedIdentity string
param containerRegistry string
param containerImagePath string
param targetPort int = 80

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: '${baseName}-law'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${baseName}-apm'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource containerAppEnv 'Microsoft.App/managedEnvironments@2024-10-02-preview' = {
  name: '${baseName}-env'
  location: location
  properties: {
    publicNetworkAccess: 'Enabled'
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
    workloadProfiles: [
      {
        name: workloadProfileName
        workloadProfileType: 'Consumption-GPU-NC8as-T4'
        // minimumCount: 0      // Causes error
        // maximumCount: 1      // Causes error
      }
    ]
  }
}

resource containerApp 'Microsoft.App/containerApps@2024-10-02-preview' = {
  name: '${baseName}-aca'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userManagedIdentity}': {}
    }
  }
  properties: {
    workloadProfileName: workloadProfileName
    managedEnvironmentId: containerAppEnv.id
    configuration: {
      ingress: {
        external: true
        targetPort: targetPort
      }
      registries: [
        {
          server: containerRegistry
          identity: userManagedIdentity
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'gpu-hello-world-container'
          imageType: 'ContainerImage'
          image: '${containerRegistry}${containerImagePath}'
          command: []
          args: []
          resources: {
              cpu: 8
              memory: '56Gi'
          }
        }
      ]
    }
  }
}

output containerAppId string = containerApp.id
output containerAppEnvId string = containerAppEnv.id

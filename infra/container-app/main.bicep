param location string = resourceGroup().location
param baseName string = 'cdw-gpuapp-20250110'
param containerImageUrl string = 'mcr.microsoft.com/k8se/gpu-quickstart:latest'
param workloadProfileName string = 'gpu-serverless'

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
        // minimumCount: 0
        // maximumCount: 1
      }
    ]
  }
}

resource containerApp 'Microsoft.App/containerApps@2024-10-02-preview' = {
  name: '${baseName}-aca'
  location: location
  properties: {
    workloadProfileName: workloadProfileName
    managedEnvironmentId: containerAppEnv.id
    configuration: {
      ingress: {
        external: true
        targetPort: 80
      }
    }
    template: {
      containers: [
        {
          name: 'gpu-hello-world-container'
          image: containerImageUrl
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

# Stable Diffusion Testing

An example of using Stable Diffusion in a containerized application that can be run in an Azure Container App, among other things.

```bash

az login -t 50b50181-4f19-4fb9-b127-6428540c3569

RG_NAME=cdw-gpuapp-20250110
LOCATION=westus3
DEPLOYMENT_NAME=deploy-aca-app
MANAGED_USER_ID=/subscriptions/99687110-f266-471f-9345-b1a19c6b6b7f/resourceGroups/rds-shared/providers/Microsoft.ManagedIdentity/userAssignedIdentities/reachdigital-acr-pull-user
REGISTRY=reachdigital.azurecr.io

# IMAGE=/comfyui/comfyui-docker:latest
# TARGET_PORT=8188

IMAGE=/k8se/gpu-quickstart:latest
TARGET_PORT=80

# REGISTRY=mcr.microsoft.com

az group create -n $RG_NAME -l $LOCATION

az deployment group create \
  --name $DEPLOYMENT_NAME \
  --resource-group $RG_NAME \
  --template-file ./infra/container-app/main.bicep \
  --parameters \
    userManagedIdentity=$MANAGED_USER_ID \
    containerRegistry=$REGISTRY \
    containerImagePath=$IMAGE \
    targetPort=$TARGET_PORT \

az deployment group delete \
  --name $DEPLOYMENT_NAME \
  --resource-group $RG_NAME

az group delete -n $RG_NAME

```
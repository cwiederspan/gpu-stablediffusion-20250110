# Stable Diffusion Testing

An example of using Stable Diffusion in a containerized application that can be run in an Azure Container App, among other things.

```bash

az login -t 50b50181-4f19-4fb9-b127-6428540c3569

BASE_NAME=cdw-gpuapp-20250111
LOCATION=westus3
DEPLOYMENT_NAME=deploy-aca-app
MANAGED_USER_ID=/subscriptions/99687110-f266-471f-9345-b1a19c6b6b7f/resourceGroups/rds-shared/providers/Microsoft.ManagedIdentity/userAssignedIdentities/reachdigital-acr-pull-user
REGISTRY=reachdigital.azurecr.io

# IMAGE=/comfyui/comfyui-docker:latest
# TARGET_PORT=8188

IMAGE=/k8se/gpu-quickstart:latest
TARGET_PORT=80

# REGISTRY=mcr.microsoft.com

az group create -n $BASE_NAME -l $LOCATION

az deployment group create \
  --name $DEPLOYMENT_NAME \
  --resource-group $BASE_NAME \
  --template-file ./infra/container-app/main.bicep \
  --parameters \
    baseName=$BASE_NAME \
    userManagedIdentity=$MANAGED_USER_ID \
    containerRegistry=$REGISTRY \
    containerImagePath=$IMAGE \
    targetPort=$TARGET_PORT \

az deployment group delete \
  --name $DEPLOYMENT_NAME \
  --resource-group $BASE_NAME

az group delete -n $BASE_NAME


az acr import -n reachdigital --source mcr.microsoft.com/k8se/gpu-quickstart:latest --image k8se/gpu-quickstart:latest

```
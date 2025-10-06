#!/bin/bash

# Set the default subscription to the Launchpad subscription:
az account set --subscription $SUBSCRIPTION_ID

# Create the backend resource group if it does not exist:
if [ $(az group exists --name $BACKEND_AZURE_RESOURCE_GROUP_NAME --subscription $SUBSCRIPTION_ID) == 'false' ]; then
    az group create --name $BACKEND_AZURE_RESOURCE_GROUP_NAME --subscription $SUBSCRIPTION_ID --location 'uksouth'
fi

# Check if the storage account name is available in the current subscription:
STORAGE_ACCOUNT_EXISTS=$(az storage account list --query "[?name=='$BACKEND_AZURE_STORAGE_ACCOUNT_NAME' && resourceGroup=='$BACKEND_AZURE_RESOURCE_GROUP_NAME'] | length(@)" --output tsv)

if [ "$STORAGE_ACCOUNT_EXISTS" -eq 0 ]; then
    echo "Creating new storage account $BACKEND_AZURE_STORAGE_ACCOUNT_NAME in resource group $BACKEND_AZURE_RESOURCE_GROUP_NAME"

    # Register Azure Storage Account provider if necessary:
    az provider register --namespace Microsoft.Storage

    # Create a new Storage Account:
    az storage account create --name $BACKEND_AZURE_STORAGE_ACCOUNT_NAME --resource-group $BACKEND_AZURE_RESOURCE_GROUP_NAME --location 'uksouth' --sku Standard_LRS --kind StorageV2 --min-tls-version TLS1_2

    # Add a lock to the storage account to prevent accidental deletion:
    az lock create --name LockHubStorage --lock-type CanNotDelete --resource-group $BACKEND_AZURE_RESOURCE_GROUP_NAME --resource-name $BACKEND_AZURE_STORAGE_ACCOUNT_NAME --resource-type 'Microsoft.Storage/storageAccounts'

    # Enable versioning in the state file to enable previous states to be recovered:
    az storage account blob-service-properties update --resource-group $BACKEND_AZURE_RESOURCE_GROUP_NAME --account-name $BACKEND_AZURE_STORAGE_ACCOUNT_NAME --enable-versioning true

else
    echo "Storage account $BACKEND_AZURE_STORAGE_ACCOUNT_NAME already exists in resource group $BACKEND_AZURE_RESOURCE_GROUP_NAME"
fi

# Create a container for the state files if it does not exist:
CONTAINER_EXISTS=$(az storage container list --account-name $BACKEND_AZURE_STORAGE_ACCOUNT_NAME --query "[?name=='$BACKEND_AZURE_STORAGE_CONTAINER_NAME'] | length(@)" --output tsv  --auth-mode login)

if [ "$CONTAINER_EXISTS" -eq 0 ]; then
    az storage container create --name "${BACKEND_AZURE_STORAGE_CONTAINER_NAME}" --account-name $BACKEND_AZURE_STORAGE_ACCOUNT_NAME --auth-mode login
    echo "Container $BACKEND_AZURE_STORAGE_CONTAINER_NAME created in storage account $BACKEND_AZURE_STORAGE_ACCOUNT_NAME"
else
    echo "Container $BACKEND_AZURE_STORAGE_CONTAINER_NAME already exists in storage account $BACKEND_AZURE_STORAGE_ACCOUNT_NAME"
fi

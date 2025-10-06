#!/bin/bash
set -e

# Set the environment variables, ensuring the script is run from the correct directory:
source "$(dirname "${BASH_SOURCE[0]}")/../../variables.sh"

tfDir="${PROJECT_ROOT}/infrastructure"
echo "Using Terraform directory: ${tfDir}"

# Store time that script execution started:
START_TIME=$(date +'%Y-%m-%dT%H:%M:%S')

# If user passed in any of the three inputs then use them, otherwise prompt for them:
if [ -z "$1" ]; then

    # Ask user which commands to perform?
    read -p "Enter commands to perform: Initialise (i), Plan (p), Apply (a) and Destroy (d)?: " applyChanges

else
    applyChanges=$1
fi

# Set subscription to the DevOps subscription to perform initialisation
echo "Setting Subscription to $SUBSCRIPTION_ID"
az account set -s $SUBSCRIPTION_ID

# if user wishes to initialise or delete:
if [[ $applyChanges =~ "i" ]] || [[ $applyChanges =~ "d" ]]; then
    echo "Configuring TF backend for ${ENVIRONMENT_NAME} in statefile ${BACKEND_AZURE_STORAGE_ACCOUNT_KEY}"

    # Ensure backend statefile has been created:
    bash "${PROJECT_ROOT}/scripts/build/backend-setup/01-statefile-setup.sh"

    terraform -chdir="${tfDir}" init \
        -reconfigure -upgrade \
        -backend-config=subscription_id=$SUBSCRIPTION_ID \
        -backend-config=resource_group_name=$BACKEND_AZURE_RESOURCE_GROUP_NAME \
        -backend-config=storage_account_name=$BACKEND_AZURE_STORAGE_ACCOUNT_NAME \
        -backend-config=container_name=$BACKEND_AZURE_STORAGE_CONTAINER_NAME \
        -backend-config=key=$BACKEND_AZURE_STORAGE_ACCOUNT_KEY 
fi

# if the user wishes to validate the configuration:
if [[ $applyChanges =~ "v" ]]; then
    echo "Validating TF for ${APPLICATION_NAME}-${ENVIRONMENT_NAME}"
    terraform -chdir="${tfDir}" validate 
fi

# if user wishes to apply changes or plan the changes, then perform the plan:
if [[ $applyChanges =~ "p" ]]; then
    echo "Creating Plan for ${APPLICATION_NAME}-${ENVIRONMENT_NAME}"
    terraform -chdir="${tfDir}" plan \
        -input=false \
        -var="application=${APPLICATION_NAME}" \
        -var="environment=${ENVIRONMENT_NAME}" \
        -var="subscription_id=${SUBSCRIPTION_ID}" \
        -var-file=${PROJECT_ROOT}/environments/${APPLICATION_NAME}-${ENVIRONMENT_NAME}.tfvars \
        -out=${PROJECT_ROOT}/scripts/build/output-files/${APPLICATION_NAME}-${ENVIRONMENT_NAME}.tfplan
fi

# If user wishes to apply changes, then apply the plan:
if [[ $applyChanges =~ "a" ]]; then
    echo "Applying TF Plan for ${ENVIRONMENT_NAME}"
    terraform -chdir="${tfDir}" apply ${PROJECT_ROOT}/scripts/build/output-files/${APPLICATION_NAME}-${ENVIRONMENT_NAME}.tfplan

    # Delete the plan file after applying:
    rm -f ${PROJECT_ROOT}/scripts/build/output-files/${APPLICATION_NAME}-${ENVIRONMENT_NAME}.tfplan
fi

# if user wishes to destroy, then destroy the environmentName:
if [[ $applyChanges =~ "d" ]]; then
    echo "Destroying TF for ${ENVIRONMENT_NAME}"
    terraform -chdir="${tfDir}" destroy \
        -var="application=${APPLICATION_NAME}" \
        -var="environment=${ENVIRONMENT_NAME}" \
        -var="subscription_id=${SUBSCRIPTION_ID}" \
        -var-file=${PROJECT_ROOT}/environments/${APPLICATION_NAME}-${ENVIRONMENT_NAME}.tfvars \
        -auto-approve

    # if user also wishes to delete the state file:
    if [[ $applyChanges =~ "x" ]]; then
        echo "Deleting state file for ${ENVIRONMENT_NAME}"
        az storage blob delete --account-name "${BACKEND_AZURE_STORAGE_ACCOUNT_NAME}" --container-name "${BACKEND_AZURE_STORAGE_CONTAINER_NAME}" --name "${BACKEND_AZURE_STORAGE_ACCOUNT_KEY}" --auth-mode login
    fi
fi

# Store time that script execution finished:
END_TIME=$(date +'%Y-%m-%dT%H:%M:%S')

# Output the start and end times:
echo "Start time: $START_TIME"
echo "End time: $END_TIME"

# Variables are set via independent script file

TERRAFORM_DIR := ../../infrastructure
TF_PLAN_FILE := $(PROJECT_ROOT)/scripts/build/output-files/$(APPLICATION_NAME)-$(ENVIRONMENT_NAME).tfplan

.PHONY: initialise validate plan apply destroy delete_state

initialise:
	@echo "Setting Subscription to $(SUBSCRIPTION_ID)"
	@az account set -s $(SUBSCRIPTION_ID)
	@echo "Configuring TF backend"
	@terraform -chdir=$(TERRAFORM_DIR) init -reconfigure -upgrade \
		-backend-config=subscription_id=$(SUBSCRIPTION_ID) \
		-backend-config=resource_group_name=$(BACKEND_AZURE_RESOURCE_GROUP_NAME) \
		-backend-config=storage_account_name=$(BACKEND_AZURE_STORAGE_ACCOUNT_NAME) \
		-backend-config=container_name=$(BACKEND_AZURE_STORAGE_CONTAINER_NAME) \
		-backend-config=key=$(BACKEND_AZURE_STORAGE_ACCOUNT_KEY)

validate:
	@echo "Validating Terraform configuration"
	@terraform -chdir=$(TERRAFORM_DIR) validate

plan:
	@echo "Creating Terraform plan"
	@terraform -chdir=$(TERRAFORM_DIR) plan -input=false \
		-var="application=$(APPLICATION_NAME)" \
		-var="environment=$(ENVIRONMENT_NAME)" \
		-var="subscription_id=$(SUBSCRIPTION_ID)" \
		-var-file=$(PROJECT_ROOT)/environments/$(APPLICATION_NAME)-$(ENVIRONMENT_NAME).tfvars \
		-out=$(TF_PLAN_FILE)

apply:
	@echo "Applying Terraform plan"
	@terraform apply $(TF_PLAN_FILE)

destroy:
	@echo "Destroying Terraform infrastructure"
	@terraform -chdir=$(TERRAFORM_DIR) destroy -auto-approve \
		-var="application=$(APPLICATION_NAME)" \
		-var="environment=$(ENVIRONMENT_NAME)" \
		-var="subscription_id=$(SUBSCRIPTION_ID)" \
		-var-file=$(PROJECT_ROOT)/environments/$(ENVIRONMENT_NAME).tfvars

delete_state:
	@echo "Deleting state file"
	@az storage blob delete --account-name "$(BACKEND_AZURE_STORAGE_ACCOUNT_NAME)" \
		--container-name "$(BACKEND_AZURE_STORAGE_CONTAINER_NAME)" \
		--name "$(BACKEND_AZURE_STORAGE_ACCOUNT_KEY)" \
		--auth-mode login

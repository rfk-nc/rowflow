
sudo apt install curl
sudo apt install diodon
sudo apt install make

# Install Terraform
wget https://releases.hashicorp.com/terraform/1.12.1/terraform_1.12.1_linux_amd64.zip
unzip terraform_1.12.1_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Clean up the downloaded zip file
rm terraform_1.12.1_linux_amd64.zip

# Verify Terraform installation
terraform -version

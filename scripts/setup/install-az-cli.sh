# There is no apt package for Ubuntu 25.04, so install via snap

#!/bin/bash
set -e
# Install snap if not installed
if ! command -v snap &> /dev/null; then
    echo "Snap is not installed. Installing snap..."
    sudo apt update
    sudo apt install -y snapd
fi

# Install Azure CLI via snap
if ! command -v az &> /dev/null; then
    echo "Azure CLI is not installed. Installing Azure CLI..."
    sudo snap install azcli
else
    echo "Azure CLI is already installed."
fi

# Create an alias so we can run `az` from anywhere
sudo snap alias azcli.az az
#!/bin/bash
set -e

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources - Note using Ubuntu 24.10 version - oracular:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu oracular stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install Docker Engine, CLI, containerd, Buildx, and Compose:
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# The docker group is created but no users are added. Add your normal user to the group to run docker commands as non-privileged user.
sudo usermod -aG docker $USER
newgrp docker

# Test:
docker run --rm -it  --name test alpine:latest /bin/sh

# Install pip if not already installed:
# if ! command -v pip &> /dev/null; then
#     sudo apt install -y python3-pip
# fi

# Install flask via apt:
sudo apt install python3-flask

# Install Python virtual environments
sudo apt install python3.13-venv

# Install kubectl:
sudo snap install kubectl --classic
#!/bin/bash

echo 'deb http://download.opensuse.org/repositories/graphics:/darktable/xUbuntu_25.04/ /' | sudo tee /etc/apt/sources.list.d/graphics:darktable.list
curl -fsSL https://download.opensuse.org/repositories/graphics:darktable/xUbuntu_25.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/graphics_darktable.gpg > /dev/null
sudo apt update
sudo apt install darktable


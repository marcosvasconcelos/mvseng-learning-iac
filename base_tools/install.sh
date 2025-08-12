#!/bin/bash

#check the python version min version expected is 3.10
if ! python3 --version | grep -q "Python 3.10"; then
    echo "❌ Python 3.10 or higher is required. Please install it and try again."
    exit 1
fi

# Add the GPG key for HashiCorp
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

# Add the HashiCorp repository
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# Update and install Terraform
sudo apt-get update && sudo apt-get install terraform

# create .venv folder if it does not exist
if [ ! -d ".venv" ]; then
    python3 -m venv .venv
fi
# install python dependencies
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

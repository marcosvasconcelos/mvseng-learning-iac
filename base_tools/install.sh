#!/bin/bash

if ! python3 --version | grep -q "Python 3.12"; then
    echo "Python 3.12 or higher is required. Please install it and try again."
    exit 1
fi
# Check if is Mac or Linux
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Install Homebrew if not installed
    if ! command -v brew &> /dev/null; then
        echo "Homebrew is not installed. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew tap hashicorp/tap
    brew install hashicorp/tap/terraform
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt-get update && sudo apt-get install terraform
else
    echo "Unsupported OS. Please install Terraform manually."
    exit 1
fi

if [ ! -d ".venv" ]; then
    python3 -m venv .venv
fi
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

#!/bin/bash

# Script to create AWS key pair if it doesn't exist
# Usage: ./create-keypair.sh

# Configuration
KEY_NAME="my-key"
AWS_PROFILE="mvseng-learning-tf"
AWS_REGION="us-east-1"
KEY_FILE="$HOME/.ssh/${KEY_NAME}.pem"

echo "🔑 Checking if AWS key pair '$KEY_NAME' exists..."

# Check if key pair exists in AWS
if aws ec2 describe-key-pairs --key-names "$KEY_NAME" --profile "$AWS_PROFILE" --region "$AWS_REGION" --output text &>/dev/null; then
    echo "✅ Key pair '$KEY_NAME' already exists in AWS"
    
    # Check if local key file exists
    if [ -f "$KEY_FILE" ]; then
        echo "✅ Local key file '$KEY_FILE' already exists"
        echo "🎉 All set! You can proceed with terraform apply"
    else
        echo "⚠️  Key pair exists in AWS but local file '$KEY_FILE' is missing"
        echo "💡 You may need to download it from AWS Console or recreate the key pair"
    fi
else
    echo "🔨 Creating new key pair '$KEY_NAME'..."
    
    # Create SSH directory if it doesn't exist
    mkdir -p "$HOME/.ssh"
    
    # Create the key pair and save the private key
    if aws ec2 create-key-pair \
        --key-name "$KEY_NAME" \
        --profile "$AWS_PROFILE" \
        --region "$AWS_REGION" \
        --query 'KeyMaterial' \
        --output text > "$KEY_FILE"; then
        
        # Set proper permissions for the private key
        chmod 600 "$KEY_FILE"
        
        echo "✅ Key pair '$KEY_NAME' created successfully!"
        echo "📁 Private key saved to: $KEY_FILE"
        echo "🔒 Permissions set to 600 (read-only for owner)"
        echo "🎉 You can now proceed with terraform apply"
    else
        echo "❌ Failed to create key pair. Please check your AWS credentials and permissions."
        exit 1
    fi
fi

echo ""
echo "📋 Summary:"
echo "   Key Name: $KEY_NAME"
echo "   AWS Profile: $AWS_PROFILE"
echo "   AWS Region: $AWS_REGION"
echo "   Local Key File: $KEY_FILE"

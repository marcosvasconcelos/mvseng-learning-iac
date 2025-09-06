#!/bin/bash
# Script to create AWS key pair if it doesn't exist
# Usage: ./create-keypair.sh

KEY_NAME="my-key-mac"
AWS_PROFILE="mvseng-learning-tf"
AWS_REGION="us-east-1"
KEY_FILE="$HOME/.ssh/${KEY_NAME}.pem"

echo "Checking key pair: $KEY_NAME"

if aws ec2 describe-key-pairs --key-names "$KEY_NAME" --profile "$AWS_PROFILE" --region "$AWS_REGION" --output text &>/dev/null; then
  echo "Exists in AWS: $KEY_NAME"

  if [ -f "$KEY_FILE" ]; then
    echo "Local key exists: $KEY_FILE"
  else
    echo "Local key missing: $KEY_FILE"
  fi
else
  echo "Creating key pair: $KEY_NAME"

  mkdir -p "$HOME/.ssh"

  if aws ec2 create-key-pair \
    --key-name "$KEY_NAME" \
    --profile "$AWS_PROFILE" \
    --region "$AWS_REGION" \
    --query 'KeyMaterial' \
    --output text > "$KEY_FILE"; then

    chmod 600 "$KEY_FILE"

    echo "Created: $KEY_FILE"
  else
    echo "Failed to create key pair"
    exit 1
  fi
fi

echo
echo "Summary:"
echo "  Key Name: $KEY_NAME"
echo "  AWS Profile: $AWS_PROFILE"
echo "  AWS Region: $AWS_REGION"
echo "  Private Key: $KEY_FILE"

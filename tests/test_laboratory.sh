#!/bin/bash
# Script to test laboratory setup by verifying connectivity
# Usage: ./test_laboratory.sh <instance_ip>
# args: [instance|alb] <IP_ADDRESS>|<ALB_DNS>
if [ $# -ne 2 ]; then
    echo "Usage: $0 [instance|alb] <IP_ADDRESS>|<ALB_DNS>"
    exit 1
fi

CONNECT_TYPE="$1"
TARGET="$2"

if [ "$CONNECT_TYPE" == "instance" ]; then
    INSTANCE_IP="$TARGET"
    echo "🌐 Testing HTTP connectivity to instance at $INSTANCE_IP..."
    if curl -I "http://$INSTANCE_IP" | head -n 1 | grep "200 OK" > /dev/null; then
        echo "✅ HTTP connection to $INSTANCE_IP is successful!"
    else
        echo "❌ Failed to connect to $INSTANCE_IP via HTTP."
        exit 1
    fi
    ssh -i ~/.ssh/my-key.pem -o ConnectTimeout=5 -o StrictHostKeyChecking=no ec2-user@"$INSTANCE_IP" 'echo "SSH connection successful!"'

elif [ "$CONNECT_TYPE" == "alb" ]; then
    ALB_DNS="$TARGET"
    echo "🌐 Testing HTTP connectivity to ALB at $ALB_DNS..."
    if curl -I "http://$ALB_DNS" | head -n 1 | grep "200 OK" > /dev/null; then
        echo "✅ HTTP connection to $ALB_DNS is successful!"
    else
        echo "❌ Failed to connect to $ALB_DNS via HTTP."
        exit 1
    fi
else
    echo "Invalid argument: $CONNECT_TYPE"
    exit 1
fi


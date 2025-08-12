#!/bin/bash
# Script simulating a failure in the balancer test
# Usage: ./balancer_test.sh stop_service <instance_ip>
# Usage: ./balancer_test.sh test_balancer <ALB_DNS>
if [ $1 -ne 1 ]; then
    echo "Usage: $0 stop_service <instance_ip> | test_balancer <ALB_DNS>"
    exit 1
fi

COMMAND="$1"
if [ $COMMAND == "stop_service" ]; then
    INSTANCE_IP=$2
    if [ -z $INSTANCE_IP ]; then
        echo "Please provide the instance IP address to stop the service."
        exit 1
    fi
    echo "🔧 Stopping service on instance at $INSTANCE_IP..."
    ssh -i ~/.ssh/my-key.pem -o ConnectTimeout=5 -o StrictHostKeyChecking=no ec2-user@"$INSTANCE_IP" 'sudo systemctl stop nginx'
    echo "✅ Service stopped on instance $INSTANCE_IP."

elif [ "$COMMAND" == "test_balancer" ]; then
    ALB_DNS="$2"
    if [ -z "$ALB_DNS" ]; then
        echo "Please provide the ALB DNS to test."
        exit 1
    fi
    echo "🌐 Testing HTTP connectivity to ALB at $ALB_DNS..."
    if curl -I "http://$ALB_DNS" | head -n 1 | grep "200 OK" > /dev/null; then
        echo "✅ HTTP connection to $ALB_DNS is successful!"
    else
        echo "❌ Failed to connect to $ALB_DNS via HTTP."
        exit 1
    fi
else
    echo "Invalid command: $COMMAND"
    exit 1
fi

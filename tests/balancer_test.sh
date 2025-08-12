#!/bin/bash

# Usage: ./balancer_test.sh stop_service <INSTANCE_IP> | test_balancer <ALB_DNS>
if [ $# -ne 2 ]; then
  echo "Usage: $0 stop_service <INSTANCE_IP> | test_balancer <ALB_DNS>"
  exit 1
fi

COMMAND="$1"
TARGET="$2"

if [ "$COMMAND" = "stop_service" ]; then
  if [ -z "$TARGET" ]; then
    echo "Instance IP required"
    exit 1
  fi
  echo "Stopping nginx on $TARGET"
  ssh -i ~/.ssh/my-key.pem -o ConnectTimeout=5 -o StrictHostKeyChecking=no ec2-user@"$TARGET" 'sudo systemctl stop nginx' || { echo "SSH/stop failed"; exit 1; }
  echo "Service stopped on $TARGET"

elif [ "$COMMAND" = "test_balancer" ]; then
  if [ -z "$TARGET" ]; then
    echo "ALB DNS required"
    exit 1
  fi
  echo "HTTP check: http://$TARGET"
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://$TARGET")
  if [ "$STATUS" = "200" ]; then
    echo "HTTP 200"
  else
    echo "HTTP failed ($STATUS)"
    exit 1
  fi
else
  echo "Invalid command: $COMMAND"
  exit 1
fi

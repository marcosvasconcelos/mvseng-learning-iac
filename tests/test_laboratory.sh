#!/bin/bash
# Usage: ./test_laboratory.sh [instance|alb] <IP_OR_DNS>
if [ $# -ne 2 ]; then
  echo "Usage: $0 [instance|alb] <IP_OR_DNS>"
  exit 1
fi

CONNECT_TYPE="$1"
TARGET="$2"

if [ "$CONNECT_TYPE" = "instance" ]; then
  echo "HTTP check: $TARGET"
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://$TARGET")
  if [ "$STATUS" = "200" ]; then
    echo "HTTP 200"
  else
    echo "HTTP failed ($STATUS)"
    exit 1
  fi

  ssh -i ~/.ssh/my-key.pem -o ConnectTimeout=5 -o StrictHostKeyChecking=no ec2-user@"$TARGET" 'echo "SSH OK"' || { echo "SSH failed"; exit 1; }

elif [ "$CONNECT_TYPE" = "alb" ]; then
  echo "HTTP check: $TARGET"
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://$TARGET")
  if [ "$STATUS" = "200" ]; then
    echo "HTTP 200"
  else
    echo "HTTP failed ($STATUS)"
    exit 1
  fi
else
  echo "Invalid argument: $CONNECT_TYPE"
  exit 1
fi


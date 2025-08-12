#!/bin/bash
# Cleanup security groups and related resources before starting the lab
# Usage: ./cleanup.sh

AWS_PROFILE="mvseng-learning-tf"
AWS_REGION="us-east-1"
VPC_NAME=""

echo "Starting cleanup..."
echo "AWS Profile: $AWS_PROFILE"
echo "AWS Region: $AWS_REGION"
echo

delete_security_group() {
  local sg_name="$1"
  echo "Checking security group: $sg_name"

  SG_ID=$(aws ec2 describe-security-groups \
    --filters "Name=group-name,Values=$sg_name" \
    --profile "$AWS_PROFILE" \
    --region "$AWS_REGION" \
    --query 'SecurityGroups[0].GroupId' \
    --output text 2>/dev/null)

  if [ "$SG_ID" != "None" ] && [ -n "$SG_ID" ]; then
    echo "Deleting security group: $sg_name (ID: $SG_ID)"
    if aws ec2 delete-security-group \
      --group-id "$SG_ID" \
      --profile "$AWS_PROFILE" \
      --region "$AWS_REGION" 2>/dev/null; then
      echo "Deleted: $sg_name"
    else
      echo "Failed to delete: $sg_name (may be in use)"
    fi
  else
    echo "Not found: $sg_name"
  fi
  echo
}

terminate_lab_instances() {
  echo "Searching for EC2 instances with tag Environment=dev..."

  INSTANCE_IDS=$(aws ec2 describe-instances \
    --filters "Name=tag:Environment,Values=dev" "Name=instance-state-name,Values=running,pending,stopping,stopped" \
    --profile "$AWS_PROFILE" \
    --region "$AWS_REGION" \
    --query 'Reservations[].Instances[].InstanceId' \
    --output text 2>/dev/null)

  if [ -n "$INSTANCE_IDS" ] && [ "$INSTANCE_IDS" != "None" ]; then
    echo "Terminating instances: $INSTANCE_IDS"
    if aws ec2 terminate-instances \
      --instance-ids $INSTANCE_IDS \
      --profile "$AWS_PROFILE" \
      --region "$AWS_REGION" >/dev/null 2>&1; then
      echo "Waiting for termination..."
      aws ec2 wait instance-terminated \
        --instance-ids $INSTANCE_IDS \
        --profile "$AWS_PROFILE" \
        --region "$AWS_REGION" 2>/dev/null
      echo "Instances terminated"
    else
      echo "Failed to terminate instances"
    fi
  else
    echo "No instances found"
  fi
  echo
}

cleanup_vpc() {
  if [ -z "$VPC_NAME" ]; then
    echo "VPC cleanup skipped (VPC_NAME not set)"
    echo
    return
  fi

  echo "Searching for VPC with Name tag: $VPC_NAME"

  VPC_ID=$(aws ec2 describe-vpcs \
    --filters "Name=tag:Name,Values=$VPC_NAME" \
    --profile "$AWS_PROFILE" \
    --region "$AWS_REGION" \
    --query 'Vpcs[0].VpcId' \
    --output text 2>/dev/null)

  if [ "$VPC_ID" != "None" ] && [ -n "$VPC_ID" ]; then
    echo "VPC found: $VPC_ID"

    echo "Disassociating non-main route tables..."
    aws ec2 describe-route-tables \
      --filters "Name=vpc-id,Values=$VPC_ID" \
      --profile "$AWS_PROFILE" \
      --region "$AWS_REGION" \
      --query 'RouteTables[?Associations[?Main==`false`]].Associations[?Main==`false`].RouteTableAssociationId' \
      --output text | xargs -r -n1 -I {} aws ec2 disassociate-route-table --association-id {} --profile "$AWS_PROFILE" --region "$AWS_REGION" 2>/dev/null

    echo "Deleting non-main route tables..."
    aws ec2 describe-route-tables \
      --filters "Name=vpc-id,Values=$VPC_ID" \
      --profile "$AWS_PROFILE" \
      --region "$AWS_REGION" \
      --query 'RouteTables[?Associations[0].Main==`false`].RouteTableId' \
      --output text | xargs -r -n1 -I {} aws ec2 delete-route-table --route-table-id {} --profile "$AWS_PROFILE" --region "$AWS_REGION" 2>/dev/null

    echo "Deleting subnets..."
    aws ec2 describe-subnets \
      --filters "Name=vpc-id,Values=$VPC_ID" \
      --profile "$AWS_PROFILE" \
      --region "$AWS_REGION" \
      --query 'Subnets[].SubnetId' \
      --output text | xargs -r -n1 -I {} aws ec2 delete-subnet --subnet-id {} --profile "$AWS_PROFILE" --region "$AWS_REGION" 2>/dev/null

    echo "Detaching and deleting internet gateways..."
    IGW_ID=$(aws ec2 describe-internet-gateways \
      --filters "Name=attachment.vpc-id,Values=$VPC_ID" \
      --profile "$AWS_PROFILE" \
      --region "$AWS_REGION" \
      --query 'InternetGateways[0].InternetGatewayId' \
      --output text 2>/dev/null)

    if [ "$IGW_ID" != "None" ] && [ -n "$IGW_ID" ]; then
      aws ec2 detach-internet-gateway --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID" --profile "$AWS_PROFILE" --region "$AWS_REGION" 2>/dev/null
      aws ec2 delete-internet-gateway --internet-gateway-id "$IGW_ID" --profile "$AWS_PROFILE" --region "$AWS_REGION" 2>/dev/null
    fi

    echo "Deleting VPC..."
    if aws ec2 delete-vpc --vpc-id "$VPC_ID" --profile "$AWS_PROFILE" --region "$AWS_REGION" 2>/dev/null; then
      echo "VPC deleted"
    else
      echo "Failed to delete VPC (dependencies may remain)"
    fi
  else
    echo "VPC not found"
  fi
  echo
}

echo "This will delete lab resources (instances, security groups, optional VPC)."
echo -n "Press Enter to continue or Ctrl+C to cancel..."
read -r

echo "Terminating instances..."
terminate_lab_instances

echo "Deleting security groups..."
delete_security_group "http-sg"
delete_security_group "ec2-instance-sg"

echo "Cleanup complete."

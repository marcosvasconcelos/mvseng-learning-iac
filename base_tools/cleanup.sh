#!/bin/bash

# Script to clean up existing security groups and resources before starting the lab
# Usage: ./cleanup-sg.sh

# Configuration
AWS_PROFILE="mvseng-learning-tf"
AWS_REGION="us-east-1"

echo "🧹 Starting cleanup of existing security groups and resources..."
echo "📋 Using AWS Profile: $AWS_PROFILE"
echo "🌍 Using AWS Region: $AWS_REGION"
echo ""

# Function to delete security group by name
delete_security_group() {
    local sg_name="$1"
    echo "🔍 Checking for security group: $sg_name"
    
    # Get security group ID by name
    SG_ID=$(aws ec2 describe-security-groups \
        --filters "Name=group-name,Values=$sg_name" \
        --profile "$AWS_PROFILE" \
        --region "$AWS_REGION" \
        --query 'SecurityGroups[0].GroupId' \
        --output text 2>/dev/null)
    
    if [ "$SG_ID" != "None" ] && [ "$SG_ID" != "" ]; then
        echo "🗑️  Deleting security group: $sg_name (ID: $SG_ID)"
        if aws ec2 delete-security-group \
            --group-id "$SG_ID" \
            --profile "$AWS_PROFILE" \
            --region "$AWS_REGION" 2>/dev/null; then
            echo "✅ Successfully deleted security group: $sg_name"
        else
            echo "⚠️  Failed to delete security group: $sg_name (may be in use by instances)"
        fi
    else
        echo "ℹ️  Security group '$sg_name' not found"
    fi
    echo ""
}

# Function to terminate EC2 instances with specific tags
terminate_lab_instances() {
    echo "🔍 Looking for lab EC2 instances..."
    
    # Get instance IDs for instances with Environment=dev tag
    INSTANCE_IDS=$(aws ec2 describe-instances \
        --filters "Name=tag:Environment,Values=dev" "Name=instance-state-name,Values=running,pending,stopping,stopped" \
        --profile "$AWS_PROFILE" \
        --region "$AWS_REGION" \
        --query 'Reservations[].Instances[].InstanceId' \
        --output text 2>/dev/null)
    
    if [ -n "$INSTANCE_IDS" ] && [ "$INSTANCE_IDS" != "None" ]; then
        echo "🛑 Found instances to terminate: $INSTANCE_IDS"
        echo "⏳ Terminating instances..."
        
        if aws ec2 terminate-instances \
            --instance-ids $INSTANCE_IDS \
            --profile "$AWS_PROFILE" \
            --region "$AWS_REGION" >/dev/null 2>&1; then
            echo "✅ Termination initiated for instances: $INSTANCE_IDS"
            echo "⏳ Waiting for instances to terminate (this may take a few minutes)..."
            
            # Wait for instances to terminate
            aws ec2 wait instance-terminated \
                --instance-ids $INSTANCE_IDS \
                --profile "$AWS_PROFILE" \
                --region "$AWS_REGION" 2>/dev/null
            
            echo "✅ All instances terminated successfully"
        else
            echo "⚠️  Failed to terminate some instances"
        fi
    else
        echo "ℹ️  No lab instances found to terminate"
    fi
    echo ""
}

# Function to delete VPC and associated resources
cleanup_vpc() {
    echo "🔍 Looking for lab VPC..."
    
    # Get VPC ID by name tag
    VPC_ID=$(aws ec2 describe-vpcs \
        --filters "Name=tag:Name,Values=my-vpc-dev" \
        --profile "$AWS_PROFILE" \
        --region "$AWS_REGION" \
        --query 'Vpcs[0].VpcId' \
        --output text 2>/dev/null)
    
    if [ "$VPC_ID" != "None" ] && [ "$VPC_ID" != "" ]; then
        echo "🗑️  Found VPC to cleanup: $VPC_ID"
        
        # Delete route table associations (except main)
        echo "🔗 Cleaning up route table associations..."
        aws ec2 describe-route-tables \
            --filters "Name=vpc-id,Values=$VPC_ID" \
            --profile "$AWS_PROFILE" \
            --region "$AWS_REGION" \
            --query 'RouteTables[?Associations[?Main==`false`]].Associations[?Main==`false`].RouteTableAssociationId' \
            --output text | xargs -n1 -I {} aws ec2 disassociate-route-table --association-id {} --profile "$AWS_PROFILE" --region "$AWS_REGION" 2>/dev/null
        
        # Delete route tables (except main)
        echo "🛣️  Cleaning up route tables..."
        aws ec2 describe-route-tables \
            --filters "Name=vpc-id,Values=$VPC_ID" \
            --profile "$AWS_PROFILE" \
            --region "$AWS_REGION" \
            --query 'RouteTables[?Associations[0].Main==`false`].RouteTableId' \
            --output text | xargs -n1 -I {} aws ec2 delete-route-table --route-table-id {} --profile "$AWS_PROFILE" --region "$AWS_REGION" 2>/dev/null
        
        # Delete subnets
        echo "🌐 Cleaning up subnets..."
        aws ec2 describe-subnets \
            --filters "Name=vpc-id,Values=$VPC_ID" \
            --profile "$AWS_PROFILE" \
            --region "$AWS_REGION" \
            --query 'Subnets[].SubnetId' \
            --output text | xargs -n1 -I {} aws ec2 delete-subnet --subnet-id {} --profile "$AWS_PROFILE" --region "$AWS_REGION" 2>/dev/null
        
        # Detach and delete internet gateway
        echo "🌍 Cleaning up internet gateway..."
        IGW_ID=$(aws ec2 describe-internet-gateways \
            --filters "Name=attachment.vpc-id,Values=$VPC_ID" \
            --profile "$AWS_PROFILE" \
            --region "$AWS_REGION" \
            --query 'InternetGateways[0].InternetGatewayId' \
            --output text 2>/dev/null)
        
        if [ "$IGW_ID" != "None" ] && [ "$IGW_ID" != "" ]; then
            aws ec2 detach-internet-gateway --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID" --profile "$AWS_PROFILE" --region "$AWS_REGION" 2>/dev/null
            aws ec2 delete-internet-gateway --internet-gateway-id "$IGW_ID" --profile "$AWS_PROFILE" --region "$AWS_REGION" 2>/dev/null
        fi
        
        # Delete VPC
        echo "🗑️  Deleting VPC..."
        if aws ec2 delete-vpc --vpc-id "$VPC_ID" --profile "$AWS_PROFILE" --region "$AWS_REGION" 2>/dev/null; then
            echo "✅ VPC deleted successfully"
        else
            echo "⚠️  Failed to delete VPC (may have remaining dependencies)"
        fi
    else
        echo "ℹ️  No lab VPC found"
    fi
    echo ""
}

# Main cleanup process
echo "🚨 WARNING: This will delete ALL lab resources (instances, security groups, VPC, etc.)"
echo "Press Ctrl+C to cancel, or Enter to continue..."
read -r

# Step 1: Terminate EC2 instances first
terminate_lab_instances

# Step 2: Delete security groups
delete_security_group "http-sg"
delete_security_group "ec2-instance-sg"

# Step 3: Clean up VPC and networking (optional - uncomment if needed)
# cleanup_vpc

echo "🎉 Cleanup completed!"
echo ""
echo "📋 What was cleaned up:"
echo "   ✅ EC2 instances with Environment=dev tag"
echo "   ✅ Security groups: http-sg, ec2-instance-sg"
echo "   ℹ️  VPC cleanup is commented out (uncomment in script if needed)"
echo ""
echo "🚀 You can now run 'terraform apply' with a clean state!"

#!../.venv/bin/python3
import boto3
import sys

# list all target groups
def list_target_groups():
    client = boto3.client('elbv2')
    response = client.describe_target_groups()
    return response['TargetGroups']
# check if target group is healthy
def check_target_group_health(target_group_arn):
    client = boto3.client('elbv2')
    response = client.describe_target_health(TargetGroupArn=target_group_arn)
    return response['TargetHealthDescriptions']
# main function to check health of all target groups
def check_all_target_groups_health():
    target_groups = list_target_groups()
    for tg in target_groups:
        print(f"Checking health for Target Group: {tg['TargetGroupName']}")
        health_descriptions = check_target_group_health(tg['TargetGroupArn'])
        for health in health_descriptions:
            print(f"Instance: {health['Target']['Id']}, Health: {health['TargetHealth']['State']}")
        print("\n")
if __name__ == "__main__":
    # argument profile_name is obrigatory
    if len(sys.argv) < 2:
        print("Usage: python check_tg_healthy.py <profile_name>")
        sys.exit(1)
    boto3.setup_default_session(profile_name=sys.argv[1], region_name='us-east-1')
    #  

    check_all_target_groups_health()








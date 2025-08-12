#!../.venv/bin/python3
import boto3
import sys


def list_target_groups():
    client = boto3.client('elbv2')
    return client.describe_target_groups()['TargetGroups']


def check_target_group_health(target_group_arn):
    client = boto3.client('elbv2')
    return client.describe_target_health(TargetGroupArn=target_group_arn)['TargetHealthDescriptions']


def check_all_target_groups_health():
    for tg in list_target_groups():
        print(f"tg: {tg['TargetGroupName']}")
        for h in check_target_group_health(tg['TargetGroupArn']):
            print(f"  target: {h['Target']['Id']} state: {h['TargetHealth']['State']}")
        print()


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: check_tg_healthy.py <profile_name>")
        sys.exit(1)

    boto3.setup_default_session(profile_name=sys.argv[1], region_name='us-east-1')
    check_all_target_groups_health()








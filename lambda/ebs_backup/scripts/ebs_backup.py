# add this script to zip archive before you upload it to S3
# eg: ebs_backup_snapshot_lambda.zip

# Handler: ebs_backup.lambda_handler


#{
#    "Version": "2012-10-17",
#    "Statement": [
#        {
#            "Sid": "Stmt1482654795000",
#            "Effect": "Allow",
#            "Action": [
#                "ec2:CreateSnapshot",
#                "ec2:DeleteSnapshot",
#                "ec2:DescribeSnapshots",
#                "ec2:DescribeInstances",
#                "ec2:CreateTags"
#            ],
#            "Resource": [
#                "*"
#            ]
#        }
#    ]
#}
#
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Effect": "Allow",
#      "Action": [
#        "logs:CreateLogGroup",
#        "logs:CreateLogStream",
#        "logs:PutLogEvents"
#      ],
#      "Resource": "arn:aws:logs:*:*:*"
#    }
#  ]
#}

import os
import boto3
import collections
import datetime
import re

def lambda_handler(event, context):
    ec = boto3.client('ec2')

    servernames = [ ]
    tagname = ""

    servernames = os.environ['servers'].split(",")

    reservations = ec.describe_instances(
        Filters=[
            {'Name': 'tag:Name', 'Values': servernames},
        ]
    ).get(
        'Reservations', []
    )

    instances = sum(
        [
            [i for i in r['Instances']]
            for r in reservations
        ], [])

    print "Found %d instance that need backing up: " % len(instances)

    to_tag_retention = collections.defaultdict(list)
    to_tag_mount_point = collections.defaultdict(list)

    for instance in instances:
        try:
            retention_days = [
                int(t.get('Value')) for t in instance['Tags']
                if t['Key'] == 'Retention'][0]
        except IndexError:
            retention_days = 3

        try:
            tagname = [
                t.get('Value') for t in instance['Tags']
                if t['Key'] == 'Name'][0]
        except IndexError:
            tagname = ''

        for dev in instance['BlockDeviceMappings']:
            if dev.get('Ebs', None) is None:
                continue
            vol_id = dev['Ebs']['VolumeId']
            dev_attachment = dev['DeviceName']
            print "Found EBS volume %s on instance %s attached to %s" % (
                vol_id, instance['InstanceId'], dev_attachment)

            snap = ec.create_snapshot(
                VolumeId=vol_id,
                Description=instance['InstanceId'],
            )

            to_tag_retention[retention_days].append(snap['SnapshotId'])
            to_tag_mount_point[vol_id].append(snap['SnapshotId'])


            print "Retaining snapshot %s of volume %s from instance %s for %d days" % (
                snap['SnapshotId'],
                vol_id,
                instance['InstanceId'],
                retention_days,
            )

            ec.create_tags(
                Resources=to_tag_mount_point[vol_id],
                Tags=[
                    {'Key': 'Name', 'Value': tagname},
                    {'Key': 'DeviceName', 'Value': dev_attachment},
                    {'Key': 'Volume', 'Value': vol_id},
                    {'Key': 'Instance', 'Value': instance['InstanceId']},
                    {'Key': 'Managed', 'Value': 'ebc_backup_snapshot_lambda.py'},
                ]
            )

    for retention_days in to_tag_retention.keys():
        delete_date = datetime.date.today() + datetime.timedelta(days=retention_days)
        delete_fmt = delete_date.strftime('%Y-%m-%d')
        print "Will delete %d snapshots on %s" % (len(to_tag_retention[retention_days]), delete_fmt)
        ec.create_tags(
            Resources=to_tag_retention[retention_days],
            Tags=[
                {'Key': 'DeleteOn', 'Value': delete_fmt},
            ]
        )

    iam = boto3.client('iam')

    """
    This function looks at *all* snapshots that have a "DeleteOn" tag containing
    the current day formatted as YYYY-MM-DD. This function should be run at least
    daily.
    """

    account_ids = list()
    try:
        """
        You can replace this try/except by filling in `account_ids` yourself.
        Get your account ID with:
        > import boto3
        > iam = boto3.client('iam')
        > print iam.get_user()['User']['Arn'].split(':')[4]
        """
        iam.get_user()
    except Exception as e:
        # use the exception message to get the account ID the function executes under
        account_ids.append(re.search(r'(arn:aws:sts::)([0-9]+)', str(e)).groups()[1])


    delete_on = datetime.date.today().strftime('%Y-%m-%d')
    filters = [
        {'Name': 'tag-key', 'Values': ['DeleteOn']},
        {'Name': 'tag-value', 'Values': [delete_on]},
        {'Name': 'tag:Name', 'Values': [tagname]},
    ]
    snapshot_response = ec.describe_snapshots(OwnerIds=account_ids, Filters=filters)


    for snap in snapshot_response['Snapshots']:
        print "Deleting snapshot %s" % snap['SnapshotId']
        ec.delete_snapshot(SnapshotId=snap['SnapshotId'])


if __name__ == "__main__":
    owner = "AlexeyEgorov"
    lambda_handler("", "")

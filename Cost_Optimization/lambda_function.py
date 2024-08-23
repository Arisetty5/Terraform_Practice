import boto3

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    
    # Fetch all snapshots
    snapshots = ec2.describe_snapshots(OwnerIds=['self'])['Snapshots']
    
    # Fetch all running instance IDs
    running_instances = ec2.describe_instances(
        Filters=[{
            'Name': 'instance-state-name',
            'Values': ['running']
        }]
    )['Reservations']
    
    running_instance_ids = [
        instance['InstanceId']
        for reservation in running_instances
        for instance in reservation['Instances']
    ]
    
    # Fetch all volumes and map them to instances
    volumes = ec2.describe_volumes()['Volumes']
    
    volume_to_instance = {}
    for volume in volumes:
        for attachment in volume['Attachments']:
            if attachment['InstanceId'] in running_instance_ids:
                volume_to_instance[volume['VolumeId']] = attachment['InstanceId']
    
    # Iterate through snapshots and delete if necessary
    for snapshot in snapshots:
        snapshot_id = snapshot['SnapshotId']
        volume_id = snapshot.get('VolumeId')
        
        # Check if the volume is associated with a running instance
        if volume_id not in volume_to_instance:
            print(f"Deleting snapshot {snapshot_id} as it is not attached to any running instance")
            ec2.delete_snapshot(SnapshotId=snapshot_id)
        else:
            print(f"Snapshot {snapshot_id} is associated with volume {volume_id} of a running instance, not deleting")

    return {
        'statusCode': 200,
        'body': 'Snapshot cleanup complete'
    }

import json
import boto3

def lambda_handler(event, context):

  ecs = boto3.client('ecs', region_name='${aws_region}')
  response = ecs.describe_services(
    cluster='${cluster_name}',
    services=[
      '${service_name}',
    ]
  )

  desired = response["services"][0]["desiredCount"]

  if desired == 0:
    ecs.update_service(
      cluster='${cluster_name}',
      service='${service_name}',
      desiredCount=1
    )
    print("Updated desiredCount to 1")
  else:
    print("DesiredCount already at 1")

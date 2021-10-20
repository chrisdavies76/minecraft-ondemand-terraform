import json
import boto3
import base64
import gzip

def lambda_handler(event, context):
  log_message = json.loads(
    gzip.decompress(
      base64.b64decode(
        event['awslogs']['data']
      )
    ).decode('utf8')
  )['logEvents'][0]['message']

  host = log_message.split(' ')[3]

  name = host.split('.')[0]

  ecs = boto3.client('ecs', region_name='${aws_region}')
  try:
    response = ecs.describe_services(
      cluster=name,
      services=[
        name,
      ]
    )
  except:
    print(f"[{name}] Can't describe service")
    return

  desired = response["services"][0]["desiredCount"]

  if desired == 0:
    ecs.update_service(
      cluster=name,
      service=name,
      desiredCount=1
    )
    print(f"[{name}] Updated desiredCount to 1")
  else:
    print(f"[{name}] DesiredCount already at 1")

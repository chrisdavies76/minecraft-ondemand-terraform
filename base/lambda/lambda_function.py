import json
import boto3
import base64
import gzip

ecs = boto3.client('ecs', region_name='${aws_region}')


def lambda_handler(event, context):
  log_events = json.loads(
    gzip.decompress(
      base64.b64decode(
        event['awslogs']['data']
      )
    ).decode('utf8')
  )['logEvents']

  names = set([
    extract_name(event['message']) for event in log_events
  ])

  for name in names:
    handle_name(name)


def extract_name(message):
  host = message.split(' ')[3]
  return host.split('.')[0]


def handle_name(name):
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

  if len(response["services"]) == 0:
    print(f"[{name}] Can't find the service")
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

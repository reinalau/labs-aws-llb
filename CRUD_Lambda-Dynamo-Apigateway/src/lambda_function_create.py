import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('movies')

def lambda_handler(event, context):
   year = event['year'] if event['year'] else '0'
   title = event['title'] if event['title'] else ''
   actors = event['actors'] if event['actors'] else ''
   
   response = table.put_item(
        Item={
            'year': year,
            'title': title,
            'info': {
                'actors': actors
            }
        }
    )
   
   return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": response
    }



import boto3
import json

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('movies')

#Lambda function to get a movie from the Dynamodb movies table    
def lambda_handler(event, context):
    title = event['title']
    response = table.get_item(
       Key={'title': title}
    )
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        "body": response
    }

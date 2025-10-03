import boto3
import decimal
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('movies')

#Lambda function to update a movie from the Dynamodb movies table

def lambda_handler(event, context):
    year = event['year']
    title = event['title'] if event['title'] else ''
    rating = event['rating'] if event['rating'] else '0.0'
    plot = event['plot'] if event['plot'] else ''
    response = table.update_item(
        Key={
            'title': title
        },
        UpdateExpression="set info.rating=:r, info.plot=:p",
        ExpressionAttributeValues={
                ':r': Decimal(str(rating)),
                ':p': plot
        },
        ReturnValues="UPDATED_NEW"
    )
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": response
    }
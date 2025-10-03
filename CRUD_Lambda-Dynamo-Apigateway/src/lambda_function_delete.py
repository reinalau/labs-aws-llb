import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('movies')

#Lambda function to delete a movie from the Dynamodb movies table

def lambda_handler(event, context):
    year = event['year']
    title = event['title']
    response = table.delete_item(
        Key={
            'title': title
        },
        ConditionExpression = "attribute_exists(info.actors)",
        ReturnValues="ALL_OLD"
    )
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": response
    }

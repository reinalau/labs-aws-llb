# Este archivo es solo referencial. El código real que ejecutan las instancias EC2 
# se encuentra embebido (in-line) dentro de la sección UserData en la Launch Template
# del archivo cloudformation/template.yaml

import boto3
import time
import os

QUEUE_URL = os.environ.get('QUEUE_URL')
REGION = os.environ.get('REGION', 'us-east-1')

sqs = boto3.client('sqs', region_name=REGION)

def poll_queue():
    print(f"Starting worker for queue: {QUEUE_URL}", flush=True)
    while True:
        try:
            response = sqs.receive_message(
                QueueUrl=QUEUE_URL,
                MaxNumberOfMessages=10,
                WaitTimeSeconds=20
            )
            
            messages = response.get('Messages', [])
            for message in messages:
                print(f"Processing message {message['MessageId']}", flush=True)
                time.sleep(3) # Simulación de trabajo largo
                
                sqs.delete_message(
                    QueueUrl=QUEUE_URL,
                    ReceiptHandle=message['ReceiptHandle']
                )
        except Exception as e:
            print(f"Error: {e}", flush=True)
            time.sleep(5)

if __name__ == '__main__':
    poll_queue()

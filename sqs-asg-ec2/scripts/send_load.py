import boto3
import uuid
import sys

def send_messages(queue_url, count):
    sqs = boto3.client('sqs')
    messages_sent = 0
    
    while messages_sent < count:
        batch = []
        batch_size = min(10, count - messages_sent)
        
        for _ in range(batch_size):
            batch.append({
                'Id': str(uuid.uuid4()),
                'MessageBody': 'Simulated task process'
            })
            
        print(f"Enviando lote de {batch_size} mensajes... ({messages_sent + batch_size}/{count})")
        sqs.send_message_batch(QueueUrl=queue_url, Entries=batch)
        messages_sent += batch_size

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Uso: python send_load.py <queue_url> <cantidad_mensajes>")
        sys.exit(1)
        
    queue_url = sys.argv[1]
    count = int(sys.argv[2])
    print(f"Enviando {count} mensajes a la cola SQS...")
    send_messages(queue_url, count)
    print("¡Generación de carga finalizada!")

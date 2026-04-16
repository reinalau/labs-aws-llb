resource "aws_sqs_queue" "dlq" {
  name                      = "worker-dlq"
  message_retention_seconds = 1209600 # 14 days
}

resource "aws_sqs_queue" "worker_queue" {
  name                       = "worker-queue"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 14400 # 4 hours
  
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })
}

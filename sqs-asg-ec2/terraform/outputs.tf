output "queue_url" {
  description = "URL of the SQS worker queue"
  value       = aws_sqs_queue.worker_queue.url
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.worker_asg.name
}

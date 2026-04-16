resource "aws_cloudwatch_metric_alarm" "queue_high" {
  alarm_name          = "worker-queue-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 10
  alarm_description   = "Scale out if queue depth >= 10"

  dimensions = {
    QueueName = aws_sqs_queue.worker_queue.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_out.arn]
}

resource "aws_cloudwatch_metric_alarm" "queue_low" {
  alarm_name          = "worker-queue-low-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 3
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 1
  alarm_description   = "Scale in if queue depth <= 1"

  dimensions = {
    QueueName = aws_sqs_queue.worker_queue.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_in.arn]
}

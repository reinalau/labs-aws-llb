data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_security_group" "worker_sg" {
  name        = "worker-sg"
  description = "Security group for SQS workers"
  vpc_id      = data.aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "worker_lt" {
  name          = "worker-launch-template"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.worker_profile.name
  }

  vpc_security_group_ids = [aws_security_group.worker_sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y python3 python3-pip
    su - ec2-user -c "pip3 install boto3 --user"

    cat << 'PYEOF' > /home/ec2-user/worker.py
    import boto3
    import time
    import os

    QUEUE_URL = os.environ.get('QUEUE_URL')
    REGION = os.environ.get('REGION', '${var.aws_region}')

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
                    time.sleep(3)
                    
                    sqs.delete_message(
                        QueueUrl=QUEUE_URL,
                        ReceiptHandle=message['ReceiptHandle']
                    )
            except Exception as e:
                print(f"Error: {e}", flush=True)
                time.sleep(5)

    if __name__ == '__main__':
        poll_queue()
    PYEOF
    
    chown ec2-user:ec2-user /home/ec2-user/worker.py

    cat << 'SYSEOF' > /etc/systemd/system/worker.service
    [Unit]
    Description=SQS Worker Process
    After=network.target

    [Service]
    Environment=QUEUE_URL=${aws_sqs_queue.worker_queue.url}
    Environment=REGION=${var.aws_region}
    ExecStart=/usr/bin/python3 /home/ec2-user/worker.py
    Restart=always
    User=ec2-user

    [Install]
    WantedBy=multi-user.target
    SYSEOF

    systemctl daemon-reload
    systemctl enable worker
    systemctl start worker
  EOF
  )
}

resource "aws_autoscaling_group" "worker_asg" {
  name                = "sqs-worker-asg"
  vpc_zone_identifier = data.aws_subnets.default.ids
  min_size            = 1
  max_size            = 4
  desired_capacity    = 1
  health_check_type   = "EC2"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.worker_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "sqs-worker-instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out-policy"
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "StepScaling"
  autoscaling_group_name = aws_autoscaling_group.worker_asg.name

  step_adjustment {
    metric_interval_lower_bound = 0
    scaling_adjustment          = 1
  }
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale-in-policy"
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "StepScaling"
  autoscaling_group_name = aws_autoscaling_group.worker_asg.name

  step_adjustment {
    metric_interval_upper_bound = 0
    scaling_adjustment          = -1
  }
}

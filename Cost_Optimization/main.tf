provider "aws" {
  region = "us-east-1" # Change to your preferred region
}

# Create an EC2 instance
resource "aws_instance" "example" {
  ami           = "ami-0e86e20dae9224db8" # Example Amazon Linux 2 AMI ID (change as necessary)
  instance_type = "t2.micro"

  tags = {
    Name = "CostOptimizationDemoInstance"
  }
}

# Create a snapshot of the EBS volume
resource "aws_ebs_snapshot" "example_snapshot" {
  volume_id = aws_instance.example.root_block_device[0].volume_id

  tags = {
    Name = "ExampleSnapshot"
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_cost_optimization_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# IAM Policy for Lambda to manage EC2 and EBS
resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_cost_optimization_policy"
  description = "Policy to allow Lambda to manage EC2 and EBS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeSnapshots",
          "ec2:DescribeInstances",
          "ec2:DeleteSnapshot",
          "ec2:DescribeVolumes"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "lambda_role_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Lambda Function to manage snapshots
resource "aws_lambda_function" "snapshot_cleaner" {
  filename         = "lambda.zip"
  function_name    = "snapshot_cleaner_function"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("lambda.zip")

  environment {
    variables = {
      LOG_LEVEL = "INFO"
    }
  }
}

# CloudWatch Event Rule to trigger Lambda periodically
resource "aws_cloudwatch_event_rule" "snapshot_cleaner_rule" {
  name        = "snapshot_cleaner_rule"
  description = "Triggers the snapshot cleaner lambda function every day"
  schedule_expression = "rate(1 day)"
}

# CloudWatch Event Target to trigger Lambda
resource "aws_cloudwatch_event_target" "snapshot_cleaner_target" {
  rule      = aws_cloudwatch_event_rule.snapshot_cleaner_rule.name
  target_id = "snapshot_cleaner_lambda"
  arn       = aws_lambda_function.snapshot_cleaner.arn
}

# Lambda permission to be invoked by CloudWatch
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.snapshot_cleaner.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.snapshot_cleaner_rule.arn
}

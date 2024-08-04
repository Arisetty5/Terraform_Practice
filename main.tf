terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.61.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_cloudformation_stack" "ec2_instance" {
  name = "ec2-instance-stack"

  parameters = {
    KeyName          = "newkey"
    InstanceType     = "t2.micro"
    AMIId            = "ami-04a81a99f5ec58529"
  }

  template_body = jsonencode({
    Parameters = {
      KeyName = {
        Type        = "String"
        Description = "Name of an existing EC2 KeyPair to enable SSH access to the instance"
      }
      InstanceType = {
        Type        = "String"
        Default     = "t2.micro"
        Description = "EC2 instance type"
      }
      AMIId = {
        Type        = "String"
        Description = "The AMI ID for the EC2 instance"
      }
    }

    Resources = {
      MyEC2Instance = {
        Type = "AWS::EC2::Instance"
        Properties = {
          KeyName      = { "Ref" = "KeyName" }
          InstanceType = { "Ref" = "InstanceType" }
          ImageId      = { "Ref" = "AMIId" }
          Tags = [
            {
              Key   = "Name"
              Value = "Primary_CF_EC2_Instance"
            }
          ]
        }
      }
    }
  })
}

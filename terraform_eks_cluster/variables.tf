variable "aws_region" {
  description = "The region in which the resources should be created"
  default = "us-east-1"
}

variable "vpc_cidr" {
  description = "The deafult range for VPC"
  default = "10.0.0.0/16"
}

variable "pub_sub_cidr" {
  description = "The Ip range of Public Subnets"
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "pri_sub_cidr" {
  description = "The Ip range of Private Subnets"
  type = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "kubernetes_version" {
  default     = 1.27
  description = "kubernetes version"
}
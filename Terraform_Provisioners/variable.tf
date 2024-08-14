variable "cidr" {
  description = "IP range for the VPC"
  default = "10.0.0.0/16"
}

variable "sub_cidr" {
  description = "IP range for subnet"
  default = "10.0.0.0/24"
}

variable "aws_instance" {
  description = "Type of EC2 instance"
  default = "t2.micro"
}

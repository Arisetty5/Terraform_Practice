provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "arisetty-sai-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length = "5"
  special = false
}
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  name = "bhargav-eks-vpc"
  cidr = var.vpc_cidr
  azs = data.aws_availability_zones.available.names
  public_subnets = [var.pub_sub_cidr[0], var.pub_sub_cidr[1]]
  private_subnets = [var.pri_sub_cidr[0], var.pri_sub_cidr[1]]
  enable_nat_gateway = true
  single_nat_gateway = true
}
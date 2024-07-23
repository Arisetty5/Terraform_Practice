# AWS Region in which VPC should be created
provider "aws" {
  region = var.region
}

# Creates a Virtual Private Cloud
resource "aws_vpc" "bhargav" {
  cidr_block = var.vpc_cidr
}

# Creates an Internet gateway for the VPC
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.bhargav.id

  tags = {
    Name = "my_igw"
  }
}

# Create Public and private Subnets in 2 availability zones
resource "aws_subnet" "public_subnet_1" {
  cidr_block        = var.public_subnet_1_cidr
  vpc_id            = aws_vpc.bhargav.id
  availability_zone = var.availability_zones[0]
}

resource "aws_subnet" "private_subnet_1" {
  cidr_block        = var.private_subnet_1_cidr
  vpc_id            = aws_vpc.bhargav.id
  availability_zone = var.availability_zones[0]
}

resource "aws_subnet" "public_subnet_2" {
  cidr_block        = var.public_subnet_2_cidr
  vpc_id            = aws_vpc.bhargav.id
  availability_zone = var.availability_zones[1]
}

resource "aws_subnet" "private_subnet_2" {
  cidr_block        = var.private_subnet_2_cidr
  vpc_id            = aws_vpc.bhargav.id
  availability_zone = var.availability_zones[1]
}

# Create Elastic IPs
resource "aws_eip" "eip_1" {
  domain    = "vpc"
  depends_on = [aws_internet_gateway.my_igw]
}

resource "aws_eip" "eip_2" {
  domain    = "vpc"
  depends_on = [aws_internet_gateway.my_igw]
}

# Create NAT gateway and allocate elastic IP to NAT gateway
resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.eip_1.id
  subnet_id     = aws_subnet.public_subnet_1.id
}

resource "aws_nat_gateway" "nat_2" {
  allocation_id = aws_eip.eip_2.id
  subnet_id     = aws_subnet.public_subnet_2.id
}

# Create Route tables for public and private subnets
resource "aws_route_table" "public" {

  vpc_id = aws_vpc.bhargav.id

  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
    
    
  }
}

resource "aws_route_table" "private_1" {
  vpc_id = aws_vpc.bhargav.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1.id
  }
  
}

resource "aws_route_table" "private_2" {
  vpc_id = aws_vpc.bhargav.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_2.id
  }
}

# Associate route tables with subnets
resource "aws_route_table_association" "public_subnet_1" {
  subnet_id = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_subnet_2" {
  subnet_id = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_subnet_1" {
  subnet_id = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_1.id
}

resource "aws_route_table_association" "private_subnet_2" {
  subnet_id = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_2.id
}

# Create Security Group for Auto Scaling Group
resource "aws_security_group" "sec_grp" {
  vpc_id = aws_vpc.bhargav.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.public_cidr]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.public_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create Launch Template for Auto scaling group
resource "aws_launch_template" "example" {
  name_prefix   = "example"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.sec_grp.id]
  }
} 


# Create an Auto Scaling group with 2 Ec2 instances
resource "aws_autoscaling_group" "scl_grp" {
  desired_capacity     = 2
  max_size             = 2
  min_size             = 2
  vpc_zone_identifier  = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }
}

# Create Auto Scaling Group Attachment
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.scl_grp.name
  lb_target_group_arn    = aws_lb_target_group.example.arn
  
}

# Create an Application Load balancer
resource "aws_lb" "lb" {
  name               = "example-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sec_grp.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}

# Create Load Balancer Listener
resource "aws_lb_listener" "example" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
}

# Create Load Balancer Target Group
resource "aws_lb_target_group" "example" {
  name     = "example-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.bhargav.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

# Create Bastion Host Security Group
resource "aws_security_group" "bastion_sg" {
  vpc_id = aws_vpc.bhargav.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.public_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create Bastion Host Instance
resource "aws_instance" "bastion" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "bastion-host"
  }
}
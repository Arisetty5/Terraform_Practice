provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "key" {
  key_name = "provisioner_key"
  public_key = file("C:/Users/Bhargav Arisetty/.ssh/id_rsa.pub")
}

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "sub" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.sub_cidr
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta" {
  subnet_id = aws_subnet.sub.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "sg" {
  name = "Sec-grp"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-sg"
  }
}

resource "aws_instance" "ec2" {
  ami = "ami-04a81a99f5ec58529"
  instance_type = var.aws_instance
  key_name = aws_key_pair.key.key_name
  vpc_security_group_ids =  [aws_security_group.sg.id]
  subnet_id = aws_subnet.sub.id

  connection {
    type        = "ssh"
    user        = "ubuntu"  
    private_key = file("C:/Users/Bhargav Arisetty/.ssh/id_rsa")  
    host        = self.public_ip
  }

  provisioner "file" {
    source = "C:/Users/Bhargav Arisetty/provisioners/app.py"
    destination = "/home/ubuntu/app.py"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Hi this is remote instance'",
      "sudo apt update -y",
      "cd /home/ubuntu",
      "sudo apt install python3-flask",
      "nohup sudo python3 app.py > app.log 2>&1 &",
    ]
  }
}






# Real time project in AWS production

This Project explains how to deploy a simple python web application in an EC2 instance which is located in private Subnet with in the VPC

# VPC Creation
A Virtual Private cloud should be created on top of AWS and inside VPC, other resources such as subnets, load balancers, internet gateways can be created

# Internet gateway
An Internet gateway should be created and attached to VPC so that VPC is secure

# Public and Private Subnets
This project is implemented in 2 availability zones. So a total of 4 subnets including private and public have been created – 2 per each availability zone

# Nat Gateways
This entire setup demands 2 NAT gateways – 1 per each availability zone. These Nat gateways are created in public subnets and are used to mask the IP address of the EC2 instances in private subnets, whenever EC2 instances try to access something from Internet.

# Elastic Ips
As the private IP address of the EC2 instances have been masked, people who wanted to access the application from outside world needs a static address and that’ll be done by Elastic IP addresses. These Ips need to be allocated to NAT gateways.

# Public Route table
There should be some sort of path for the traffic to flow inside the VPC and that is served by route tables. A public route table is created which establishes a connection between Internet gateway and public subnet. 

# Private Route table
The connection between public subnet and private subnet is served by Private Route table. It ensures that traffic flows from Nat gateway to the EC2 instance which is inside the private subnet.

# Security Group
Ec2 instances should be created inside the private Subnets and whenever there is a request to access the application these EC2 instances, by default AWS blocks all kind of Internal traffic. To access the application inside the EC2 instance a security group needs to be created and configured with the correct port in which the application is deployed.

# Auto Scaling Group
This Serves as a primary function to scale up the servers in peak times and scale them down when there are less requests. An Auto scaling group needs to be created in each of the private subnets so that it can scale up the EC2 instances to 3, 4 etc when required

# Application Load Balancer
To ensure there is a smooth flow of traffic to both the EC2 instances, an Application load balancer needs to be created in public subnets. If there are 100 requests from outside world, ALB routes 50 requests to 1 instance and remaining 50 to the other instance

# Bastion Host
This is very import. By Default, EC2 instances in the private subnet can’t be accessed as they’re completely secured. Another EC2 instance is needed here called as Bastion host. The 2 EC2 instances inside the private subnets can be accessed from bastion host.
This is an end-to-end implementation of AWS project which is used in real time production basis.


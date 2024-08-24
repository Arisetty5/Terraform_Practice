resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "all_worker_mgmt_ingress" {
    description = "Allow all traffic from EKS"
    from_port = "0"
    to_port = "0"
    protocol = "-1"
  security_group_id = aws_security_group.all_worker_mgmt.id
  type = "ingress"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
}

resource "aws_security_group_rule" "all_worker_mgmt_egress" {
    description = "Allow all traffic to all"
    from_port = "0"
    to_port = "0"
    protocol = "-1"
  security_group_id = aws_security_group.all_worker_mgmt.id
  type = "egress"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
}  
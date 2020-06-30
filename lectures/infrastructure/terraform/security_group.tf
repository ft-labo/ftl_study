resource "aws_security_group" "terraform_example_ec2_sg" {
  name = "terraform-example-ec2-sg"
  description = "Allow SSH access"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",
      aws_vpc.main.cidr_block
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "terraform-example-sg"
  }
}

resource "aws_security_group" "terraform_example_rds_sg" {
  name = "terraform-example-rds-sg"
  description = "Allow mysql access from EC2 instance"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "MySQL"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = [
      aws_subnet.private1.cidr_block,
      aws_subnet.private2.cidr_block
    ]
    security_groups = [
      aws_security_group.terraform_example_ec2_sg.id
    ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "terraform-example-rds-sg"
  }
}
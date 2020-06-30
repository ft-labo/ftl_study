# EC2 Instance
resource "aws_instance" "example" {
  # Amazon Linux 2 AMI 2.0.20200406.0 x86_64 HVM
  ami = "ami-0f310fced6141e627"
  vpc_security_group_ids = [
    aws_security_group.terraform_example_ec2_sg.id
  ]
  subnet_id = aws_subnet.public.id
  key_name = aws_key_pair.example.id
  instance_type = "t2.micro"

  tags = {
    Name = "terraform-example"
  }
}

# Elastic IP
resource "aws_eip" "example" {
  instance = aws_instance.example.id
  vpc = true
}

# Key Pair
resource "aws_key_pair" "example" {
  key_name = "terraform-example"
  public_key = file("./example.pub")
}
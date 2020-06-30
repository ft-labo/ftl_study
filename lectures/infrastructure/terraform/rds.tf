resource "aws_db_subnet_group" "example" {
  name = "terraform-example-subnet-group"
  subnet_ids = [
    aws_subnet.private1.id,
    aws_subnet.private2.id
  ]
  tags = {
    Name = "terraform-example-subnet-group"
  }
}

resource "aws_db_instance" "example" {
  allocated_storage = 20
  storage_type = "gp2"
  engine = "mysql"
  engine_version = "5.7"
  instance_class = "db.t2.micro"
  name = "terraform_example_db"
  username = "terraform"
  password = "terraform123"
  skip_final_snapshot = true

  # RDSをプライベートサブネットに所属させる
  db_subnet_group_name = aws_db_subnet_group.example.name
  # RDS自体のセキュリティグループを設定する
  vpc_security_group_ids = [
    aws_security_group.terraform_example_rds_sg.id
  ]
  parameter_group_name = "default.mysql5.7"
}
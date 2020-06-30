resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  # インスタンスは共有

  tags = {
    Name = "terraform-example"
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "terraform-example/public"
  }
}

resource "aws_subnet" "private1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "terraform-example/private1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "terraform-example/private2"
  }
}

resource "aws_internet_gateway" "terraform_example" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "terraform-example/igw"
  }
}

resource "aws_route_table" "terraform_example" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "terraform-example/public-rtb"
  }
}

resource "aws_route" "terraform_example" {
  gateway_id = aws_internet_gateway.terraform_example.id
  route_table_id = aws_route_table.terraform_example.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "terraform_example" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.terraform_example.id
}

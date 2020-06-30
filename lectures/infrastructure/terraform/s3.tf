resource "aws_s3_bucket" "example" {
  bucket = "jp.co.tfl.terraform.example"
  acl = "private"
  region = "ap-northeast-1"

  tags = {
    Name = "Terraform example bucket"
  }
}
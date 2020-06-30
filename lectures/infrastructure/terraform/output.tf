# apply後にElastic IPのパブリックIPを出力する
output "ec2_public_ip" {
  value = aws_eip.example.public_ip
}

# apply後にRDSのエンドポイントを出力する
output "rds_endpoint" {
  value = aws_db_instance.example.endpoint
}
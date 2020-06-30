provider "aws" {
  profile = "default"
  version = "~> 2.0"
  region = "ap-northeast-1"
}

terraform {
  backend "s3" {
    # bucket名
    bucket = "ftl-tfstate-store"
    # tfstateファイルの保存先
    key = "learning-terraform/terraform.tfstate"
    region = "ap-northeast-1"
    # AWS IAMプロファイル（アクセスキーが１つなら不要）
    profile = "default"
  }
}

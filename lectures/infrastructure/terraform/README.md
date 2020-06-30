# leaning-terraform

## terraformのインストール

```sh
$ brew install terraform
```

## terraformの実行

- terraformのスクリプト実行に必要な秘密鍵をダウンロードする
  - 秘密鍵・公開鍵は1Passwordで共有しているものを使用すること
  - 「terraformサンプルec2秘密鍵」の添付ファイル２つをプロジェクト配下にダウンロードする

- 初期設定

```
$ terraform init
```

- terraformの設定内容の適用

```sh
$ terraform plan
$ terraform apply

// 実行後にEC2インスタンスのIPアドレスとRDSの接続先が表示される
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

ec2_public_ip = x.x.x.x
rds_endpoint = yyyy.ap-northeast-1.rds.amazonaws.com:3306
```

- terraformで構築したリソースの削除

```sh
$ terraform destroy
```

## 構築されたEC2インスタンスへの接続

- EC2にSSH接続するために秘密鍵を使用する
  - 秘密鍵・公開鍵は1Passwordで共有しているものを使用すること
  - 「terraformサンプルec2秘密鍵」の添付ファイル２つをプロジェクト配下にダウンロードして以下のコマンドを実行

```sh
// "x.x.x.x" は `terraform apply` で表示された ec2_public_ip
$ ssh -i ./example ec2-user@x.x.x.x
```

## 構築されたRDSインスタンスへの接続

- EC2インスタンスからRDSに接続する
  - 上記のEC2にSSHでログインした状態で以下のコマンドを実行

```sh
// mysqlコマンドを使うため初回のみ実施
$ sudo yum install -y mysql

// -h で指定するRDSのエンドポイントは `terraform apply` で表示された rds_endpoint
// dbのパスワードは terraform123
$ mysql -h yyyy.ap-northeast-1.rds.amazonaws.com -P 3306 -u terraform -p

// 以下のように表示され、mysqlのコンソールに接続できれば成功
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MySQL connection id is 18
Server version: 5.7.22 Source distribution

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
```

## その他Tips

- terraformの設定内容の一部適用
  - `resource` は例えば `aws_batch_compute_environment.terraform_example_batch` のように設定する

```sh
$ terraform plan -target={resource}
$ terraform apply -target={resource} 
```
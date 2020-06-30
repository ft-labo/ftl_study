# 目次

- 調査の背景
- なぜTerraformを使うのか？
- Terraformとは
- Terraformを使ったAWSリソース構築
  - インストール方法
  - 基本的なコマンド
  - 文法
  - スクリプトの構成
  - 環境の切り替え
- デモンストレーション
- 質疑応答

---

# 調査の背景

## 課題

- AWSリソースの作成をマネジメントコンソールから実施
  - 環境を引き継ぎする際にどのようなリソースが必要で、誰が何を追加したのかわかりにくい

## 解決策

- Terraformのようなオーケストレーションツールには以下のような利点がある
  - AWSリソースの設定内容を設定ファイルとして記述できる
  - また、オーケストレーションツールを導入すれば今後の開発時に環境構築/削除を自動化できる

→ オーケストレーションツールを調査することに

---

# なぜTerraformを使うのか？

- AWS環境で使用できるツールは複数ある
  - CloudFormation, Terraform, Pulumi, AWS CDK など
  - AnsibleやChefなども存在するが今回はクラウドリソースのオーケストレーションに限定
 
---

## オーケストレーションツールの比較

|  ツール          |  記述言語                   | 対象    | リリース  | 開発元 |
| ----            | ----                      | ---    | ---      | ---   |
| CloudFormation  | JSON/YAML                 | AWSのみ | 2011年    | AWS  |
| Terraform       | HCL(DSL)                  | AWS, GCP, Azureなど | 2014年 | HashiCorp |
| Pulumi          | Typescript/Python等       | AWS, GCP, Azureなど | 2017年 | Pulumi |
| AWS CDK         | Typescript/Python等       | AWSのみ | 2019年 | AWS |

- Terraformの選定理由
  - 対象となるクラウドのプロバイダーが多い
  - 記述言語が扱いやすい
  - 最初のリリースから時間が経っており比較的枯れている

---

# Terraformとは

- [Introduction to Terraform](https://www.terraform.io/intro/index.html) より
  - インフラストラクチャを安全かつ効率的に構築、変更、バージョン管理するためのツール
  - 複数のクラウドサービスに使用できる(AWS, GCP, Azureなど)
  - 必要なインフラリソースの設定値をTerraformに記述すると、Terraformは、目的の状態に到達するために何を行うかを記述した実行計画を生成し、それを実行して、記述されたインフラストラクチャを構築する
  - 構成が変更されると、Terraformは何が変更されたかを判別し、適用可能な増分実行プランを作成できる

---

# Terraformを使ったAWSリソース構築
- インストール方法
- 基本的なコマンド
- 文法
- スクリプトの構成
- 環境の切り替え

---

# Terraformを使ったAWSリソース構築
## インストール方法

- Macではbrewでインストールできる

```sh
$ brew install terraform
```

---

## 基本的なコマンド

### 初期化
- Terraformが管理するtfstateファイル（リソースの状態管理）を作成する
- tfstateファイルはS3やDynamoDBで管理できる

```
$ terraform init
```

### 環境との差分検出＆変更の適用
```
$ terraform plan
$ terraform apply
```

### リソースの削除
```
$ terraform destroy
```

---

## 文法

- JSON互換のHCL(HashiCorp Configuration Language)という言語を使う
- AWSのリソースごとにDSLが定義されており書きやすい
- InteliJのプラグインを使えばコードが補完される

```hcl-terraform
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
```

---

## スクリプトの構成

- [Standard Module Structure](https://www.terraform.io/docs/modules/index.html#standard-module-structure) より

```sh
$ tree minimal-module/
.
├── README.md
├── main.tf
├── variables.tf
├── outputs.tf
```

- main.tf
  - リソース作成のエントリーポイントとして作成
  - 複雑なものはmoduleに分ける
- [variables.tf](https://www.terraform.io/docs/configuration/variables.html)
  - 可変の設定をvariableとして定義できる
- [outputs.tf](https://www.terraform.io/docs/configuration/outputs.html)
  - terraformで環境構築後に出力される値を定義できる(ARNやElastic IPなど)

---

## 環境の切り替え

- workspaceサブコマンドで構築する環境を分けられる

### 環境情報を作成
```sh
$ terraform workspace new dev
```

### 実行する環境を選択
```sh
$ terraform env select dev
```

### DSLの中で環境情報を参照

```hcl-terraform
resource "aws_instance" "example" {
  tags = {
    Name = "terraform-example-${terraform.env}"
  }
}
```

---

# デモンストレーション

- 構築する環境
  - EC2インスタンス
  - RDSインスタンス
  - S3バケット

---

# 質疑応答

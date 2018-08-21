# データ構造体の隔離

---
# データ構造体の隔離のポイント
* 外部データの構造に依存しないように、データ構造体というクラスに変換してそっちを使う。

## 外部データの例
* データベースからの取得データ
* WebAPIからの取得データ

## 構造の例
* 取得できる配列の階層構造や名付けルール
* 取得できるJSONの階層構造や名付けルール

---
# ケーススタディ
* 商品情報閲覧のプログラムを作りたい。
* DBから商品情報を受け取り、商品情報を表示する。

### 商品（products）テーブルの構造

| フィールド名 | 内容                 |
|--------------|----------------------|
| id           | 一意となる商品識別子 |
| namae        | 商品名               |
| kakaku       | 基本価格             |

---
## フレームワークが提供している想定のDataBaseクラス
<span style="color:gray;">※これはこちらで作るものではないという想定</span>

```
class DataBase {
  /**
   * データ取得
   *
   * @param string テーブル名
   * @param string テーブル内で一意になる識別子
   * @return array 連想配列
   *               [テーブルのフィールド名 => 値] 
   */
  public static function get($table_name, $id){
    //省略
  }
}
```

---
# [サンプルコード1] 商品情報表示
* テーブルのフィールド名をそのまま使って配列のキーとする。

### 商品情報取得（Controller）

```php
$product = DataBase::get('products', 'sample');
```

### 商品情報出力（View）
* 一覧画面や詳細画面など多くの場所に登場する処理

```html
識別子 : <?php echo($product['id']); ?><br>
商品名 : <?php echo($product['namae']); ?><br>
価格   : <?php echo($product['kakaku']); ?><br>
```

---
# シミュレーション : 変更が発生
* テーブルのフィールド名は日本語のローマ字表記じゃなくてきちんと英語にしよう
* 任意の一意な文字列をユーザーが入力して付ける識別子のフィールド名は「id」ではなく「code」にしよう

### 商品（products）テーブルの構造を修正

| 変更前 | 変更後 | 内容                 |
|--------|--------|----------------------|
| id     | code   | 一意となる商品識別子 |
| namae  | name   | 商品名               |
| kakaku | price  | 基本価格             |

---
# 変更に伴う修正

### 商品情報出力（View）

```html
識別子 : <?php echo($product['code']); ?><br> ←変更
商品名 : <?php echo($product['name']); ?><br> ←変更
価格   : <?php echo($product['price']); ?><br> ←変更
```

↓  
商品情報の表示箇所は複数ある
* 商品一覧（管理側 / フロント側）
* 商品詳細（管理側 / フロント側）
* 本日の特売品一覧（管理側 / フロント側）

…

これらすべてで変更しなくてはならなくなった。

---
# 問題点
* テーブルの構造が変更されると、テーブルの構造を配列のキーなどにしてそのまま利用している箇所全てにおいて修正が求められる。

↓  
このプログラムの書き方を「変更に強く」なるように改良したい。

↓  
「データ構造体の隔離」という考え方が利用可能。

---
# データ構造体の隔離とは
- 外部データなど、配列の構造についての知識は「一箇所」で把握されるべき
- データ構造をStructなどの構造体やクラスを利用する
    - ２次元配列をStructの配列に「変換」する、など
    - 構造に変更が発生しても、修正するのは「変換」の処理を書いた１箇所で済む

### 解説
- 例えばメソッドの引数でデータ構造体を受け取り、その[0]を特定のデータ（身長や値段とか）として受け取るようなことはしない
- そのメソッドはデータ構造に依存してしまい、データ構造に変更があるたびにそのメソッドの処理を変更する必要がある
- その方法は別の開発者に複製され、プロジェクト全体に影響が出る
- 複雑な構造への直接の参照は混乱を招くので避ける

---
# [サンプルコード2-1] 商品データ構造体
* productsのテーブル構造を知っているのはこのクラスだけにする

<span style="font-size: smaller;">

```
class Product {
  private $code;  //識別子
  private $name;  //商品名
  private $price; //価格

  // ゲッター
  public function getCode() { return $this->code; }
  public function getName() { return $this->name; }
  public function getPrice(){ return $this->price; }

  // コンストラクタ テーブル構造の変換
  public function __construct(array $params){
    $this->code  = $params['code'];
    $this->name  = $params['name'];
    $this->price = $params['price'];
  }

  //DBから取得
  public static function get(string $code): Product{
    $params = DataBase::get('products', $code);
    return new Product($params);
  }
}
```

</span>

---
# [サンプルコード2-2] 商品情報表示
* データ構造体クラス「Product」を利用

### 商品情報取得（Controller）

```php
$product = Product::get('sample');
```

### 商品情報出力（View）

```html
識別子 : <?php echo($product->getCode()); ?><br>
商品名 : <?php echo($product->getName()); ?><br>
価格   : <?php echo($product->getPrice()); ?><br>
```

↓  
テーブルのフィールド名が変更になってもViewの出力部分は影響を受けない。

---
# シミュレーション : 更に変更が発生
* フィールド名にプレフィックス「p_」を付けたい

### 商品（products）テーブルの構造を修正

| 変更前 | 変更後  | 内容                 |
|--------|---------|----------------------|
| code   | p_code  | 一意となる商品識別子 |
| name   | p_name  | 商品名               |
| price  | p_price | 基本価格             |

---
# 変更に伴う修正
* Productクラスのコンストラクタのみ

```
  // コンストラクタ テーブル構造の変換
  public function __construct(array $params){
    $this->code  = $params['p_code'];
    $this->name  = $params['p_name'];
    $this->price = $params['p_price'];
  }
```

↓  
この一箇所だけ変更すればよく、商品の出力箇所全部を修正する必要がない。

↓  
より「変更に強い」プログラムになったと言える。

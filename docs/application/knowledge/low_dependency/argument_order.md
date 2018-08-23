# 引数の順番への依存を取り除く

---
# ケーススタディ
Warshipクラスを用意し、パラメータを変えて様々な軍艦インスタンスを作る。

<span style="font-size:smaller;">

```
class Warship {
  （プロパティ省略）

  public function __construct(
    $code,    // 識別子
    $name,    // 名前
    $defence, // 防御力
    $hp       // ヒットポイント
    $type,    // タイプ
    $attack,  // 攻撃力
  ){
    //省略
  }
}
```

### インスタンスの生成
```
$dd = new Warship('d1', '島風', 10,  20, 'destroyer',  10);
$cr = new Warship('c1', '川内', 30,  60, 'cruiser',    50);
$bs = new Warship('b1', '陸奥', 60, 100, 'battleship', 80);
```
</span>

---
# 変更シミュレーション
* 引数の順序がわかりにくいので直そう
* [変更前]識別子・名前・防御力・ヒットポイント・タイプ・攻撃力
* [変更後]識別子・名前・タイプ・ヒットポイント・攻撃力・防御力

---

<span style="font-size:smaller;">

```
class Warship{
  （プロパティ省略）

  public function __construct(
    $code,    // 識別子
    $name,    // 名前
    $type,    // タイプ
    $hp,      // ヒットポイント
    $attack,  // 攻撃力
    $defence  // 防御力
  ){
    //省略
  }
}
```

### インスタンスの生成
```
$dd = new Warship('d1', '島風', 'destroyer',   20,  20, 10); // 変更
$cr = new Warship('c1', '川内'  'cruiser',     60,  70, 50); // 変更
$bs = new Warship('b1', '陸奥', 'battleship', 100, 100, 80); // 変更
```

</span>

---
# 問題点
* 軍艦のパラメータの仕様はまだあやふやで変更が多そう。
* 新しい項目が増えたり不要項目が減ったりしそう。
* データベーステーブル構造の変更に伴ってそれに一致するように引数の順番が変更されたりしそう。
* 引数の順番が変わるたびに呼び出し箇所全部で修正しなくてはならなくなる。

↓  
メソッドの引数の変更は常に他のクラスでも変更を強いる。  
↓  
これを改善したい。

---
# 引数の順番への依存を取り除く 具体的には
- ハッシュ（連想配列）で引数を取る
- 現実的にはオプションはハッシュにし、変更の可能性が低い第一、第二引数のみを指定することが多い

---
# ケーススタディにおいては
## 変更されにくそう → 第一・第二引数にする
* 識別子
* 名前

## 変更されやすそう → ハッシュにする
* タイプ
* ヒットポイント
* 攻撃力
* 防御力

---
# 修正

```
class Warship{
  （プロパティ省略）

  /**
   * @param string 識別子
   * @param string 名前
   * @param array  ステータス項目の連想配列
   */
  public function __construct($code, $name, $params){
    $this->code    = $code;
    $this->name    = $name;
    $this->type    = $params['type'];
    $this->hp      = $params['hp'];
    $this->attack  = $params['attack'];
    $this->defence = $params['defence'];
  }
}
```

---
### インスタンスの生成

<span style="font-size:smaller;">

```
$dd = new Warship('d1', '島風', [
  'type'    => 'destroyer',
  'hp'      => 20,
  'attack'  => 20,
  'defence' => 10
]);

$cr = new Warship('c1', '川内', [
  'type'    => 'cruiser',
  'hp'      => 60,
  'attack'  => 70,
  'defence' => 50
]);

$bs = new Warship('b1','陸奥', [
  'type'    => 'battleship',
  'hp'      => 100,
  'attack'  => 100,
  'defence' =>  80
]);
```

</span>

---
# 改善点
* 「攻撃力」「防御力」といった、仕様が度々変更されそうな細かいステータス要素をハッシュにまとめたことで、メソッドに渡す順番が問われなくなった。
* 仮にそれらのステータス項目に増減があっても、順番を気にせずに配列への追加/削除をするだけで良い。

↓  
メソッドの引数において変更しやすい部分をハッシュにまとめたことで、引数の細かい順番変更にいちいち対応しなくてはならない頻度を減らすことができた。  
よって、より「変更が容易」になったと言える。

---
# 変更例1-1
* 任意の項目「あだ名」が追加される

<span style="font-size:smaller;">

```
class Warship{
  public function __construct($code, $name, $params){
    $this->code     = $code;
    $this->name     = $name;
    $this->type     = $params['type'];
    $this->hp       = $params['hp'];
    $this->attack   = $params['attack'];
    $this->defence  = $params['defence'];
    $this->nickname = isset($params['nickname'])
      ? $params['nickname'] : ''; // 追加
  }
}
```

```
$dd = new Warship('d1', '島風', [
  'type'     => 'destroyer',
  'hp'       => 20,
  'attack'   => 20,
  'defence'  => 10,
  'nickname' => 'ぜかまし' // 追加
]);
//「川内」「陸奥」は設定値を持たず、変更不要
```

</span>

---
# 変更例1-2
* 任意の項目「あだ名」が追加される
* オプションをハッシュ化しないケースではどうなるか
* あだ名の引数は名前の次に来る

```
class Warship {
  （プロパティ省略）

  public function __construct(
    $code,            // 識別子
    $name,            // 名前
    $nickname = null, // あだ名（任意）
    $defence,         // 防御力
    $hp               // ヒットポイント
    $type,            // タイプ
    $attack,          // 攻撃力
  ){
    //省略
  }
}
```

---

### インスタンスの生成

```
$dd = new Warship(
  'd1', '島風', 'ぜかまし', 10,  20, 'destroyer',  10);

$cr = new Warship(
  'c1', '川内', null,      30,  60, 'cruiser',    50);

$bs = new Warship(
  'b1', '陸奥', null,      60, 100, 'battleship', 80);
```

↓  
「あだ名」は任意の項目なのに引数リストの中間に現れることで設定値を持たない「川内」「陸奥」のインスタンス化においても処理を修正しなくてはならなくなった。

↓  
引数にハッシュをうまく使うことで「変更を容易」にすることができていたと言える。
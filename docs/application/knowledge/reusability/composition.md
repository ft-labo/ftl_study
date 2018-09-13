# コンポジション
* 講義実施者 :
* 講義実施日 :

---
# 概要
* コンポジション（合成）とは、あるクラスの機能を拡張する際、そのクラスのインスタンスをプロパティとして保持しそれを利用する別のクラスを作成するという手法。
* 継承と同じようなケースで利用される手法で、継承よりもこちらを利用したほうが適切であるというケースがある。

<span style="font-size:smaller;">

```
class ExpandedHelloWorld {
  private $hello_world;

  public function __construct(HelloWorld $hello_world) {
    $this->hello_world = $hello_world;
  }

  public function hello() {
    echo $this->hello_world->hello().' And goodbye.';
  }
}
```

</span>

---
# ケーススタディ
* ある布団メーカーの直販サイト。
* 商品購入者に対してノベルティ（景品）を差し上げるキャンペーンを実施する。
* 商品とそれに付属するノベルティとをセットにしてクラスで表現したい。
* 商品にはフレームワークの用意する基底クラス「Item」がある。

---
# 商品とノベルティの組み合わせ

<table>
  <tr>
    <th valign="top">セット名</th>
    <th valign="top">商品</th>
    <th valign="top">価格</th>
    <th valign="top">ノベルティ</th>
  </tr>
  <tr>
    <td valign="top">掛け布団セット</td>
    <td valign="top">掛け布団</td>
    <td valign="top">6000</td>
    <td valign="top">オリジナルボールペン</td>
  </tr>
  <tr>
    <td valign="top">敷布団セット</td>
    <td valign="top">敷布団</td>
    <td valign="top">10000</td>
    <td valign="top">オリジナル万年筆</td>
  </tr>
  <tr>
    <td valign="top">枕セット</td>
    <td valign="top">枕</td>
    <td valign="top">2500</td>
    <td valign="top">オリジナルメモ帳</td>
  </tr>
</table>


---
# サンプルプログラム
## Item（商品） : フレームワークが定義している

<span style="font-size:smaller;">

```
class Item {
  public function __construct($params) {}
  public function getName() {}
  public function getPrice() {}
  public function getCode() {}
  // 以下メソッド多数
}
```

</span>

## Novelty（景品）

<span style="font-size:smaller;">

```
class Novelty {
  public function __construct($name) {}
  public function getName() {}
}
```

</span>

---
# 継承を利用
## ノベルティ付き商品を継承で表現する
商品であることには変わりないので「Item」クラスを継承する。

<span style="font-size:smaller;">

```
class ItemWithNovelty extends Item {
  private $novelty;

  public function __construct($params, $novelty) {
    parent::__construct($params);
    $this->novelty = $novelty;
  }

  public function getSetName() {
    return $this->getName().'セット';
  }

  public function getNovelty() {
    return $this->novelty->getName();
  }
}
```

</span>


---
### Controller

<span style="font-size:smaller;">

```
$items = [
  new ItemWithNovelty(
    ['name' => '掛け布団', 'price' => 6000],
    new Novelty('オリジナルボールペン')
  ),
  new ItemWithNovelty(
    ['name' => '敷布団', 'price' => 10000],
    new Novelty('オリジナル万年筆')
  ),
  new ItemWithNovelty(
    ['name' => '枕', 'price' => 2500],
    new Novelty('オリジナルメモ帳')
  ),
];
```

</span>

### View

<span style="font-size:smaller;">

```
foreach ($items as $item) {
  セット名 : <?php echo $item->getSetName(); ?><br>
  商品 : <?php echo $item->getName(); ?><br>
  価格 : <?php echo $item->getPrice(); ?><br>
  ノベルティ : <?php echo $item->getNovelty(); ?><br>
}
```

</span>

---
# 仕様追加
* 商品-ノベルティの数量の対応を増やしたい。
  * 一対一（現状はこれのみ）
  * 一対他
  * 他対一
  * 他対他

<table>
  <tr>
    <th valign="top">セット名</th>
    <th valign="top">商品</th>
    <th valign="top">価格</th>
    <th valign="top">ノベルティ</th>
  </tr>
  <tr>
    <td valign="top">掛け布団セット</td>
    <td valign="top">掛け布団, </td>
    <td valign="top">6000</td>
    <td valign="top">オリジナルボールペン<br>オリジナルメモ帳</td>
  </tr>
  <tr>
    <td valign="top">枕お得セット</td>
    <td valign="top">枕, 枕, </td>
    <td valign="top">5000</td>
    <td valign="top">
      特別クーポン券<br>
      オリジナルボールペン<br>
      オリジナル万年筆<br>
      オリジナルメモ帳
    </td>
  </tr>
</table>

---
# プログラム修正
* 複数のノベルティに対応するため、ItemWithNovelty のノベルティプロパティを配列にする。

<span style="font-size:smaller;">

```
class ItemWithNovelty extends Item {
  private $novelties;

  public function __construct($item_params, $novelties) {
    parent::__construct($item_params);
    $this->novelties = $novelties;
  }

  public function getNovelty() {
    $noveltyStr = '';
    foreach ($this->novelties as $novelty) {
      $noveltyStr .= $novelty->getName().'<br>';
    }
    return $noveltyStr;
  }
}
```

</span>

↓  
しかしこれで対応できるのは「一対一」「一対多」のみ。

---
# 問題
では商品側が複数になる場合をどう表現する？

↓  
継承を用いているとこのケースへの対応が困難。

↓  
コンポジションなら対応可能ではないか。

---
# コンポジションとは
* クラスの機能を拡張したい場合に利用する手法。
* 拡張したいクラスのインスタンスをprivate/protectedなプロパティとして保持する。
* そのインスタンスを経由してメソッドを利用する。

# コンポジションは使い所が継承と似ている
* あるクラスの機能を拡張したい時、継承を用いて実現することもできるし、コンポジションを用いて実現することもできる。

---
# 「継承よりコンポジション」とは
* 継承を多用せず、継承が不適切なケースではコンポジションを利用すべきという考え方。
* 先人の知見が存在する。
* 『EFFECTIVE JAVA （第2版）』という書籍で提示されたのが代表例。

---
# 継承を用いると
* サブクラスはスーパークラスの全てであり、且つ、より詳細な部分を持つという関係にならねばならない。
* 「サブクラス is a スーパークラス」の関係。
* 「特殊 - 一般」の関係。
* サブクラスはスーパークラスに依存するので、スーパークラスの処理が変更されることでサブクラスの挙動も釣られて変わってしまうことがある。
* コンポジションに比べて書かねばならないコードの量は少なくなる。
* スーパークラスに選べる対象はひとつだけ。
* スーパークラスのすべてを引き受けることになる。利用したいのが一部分だけでも不要な部分を含んだ全体を引き受けることになる。

---
# コンポジションを用いると
* 「利用するクラス has a 利用されるクラス」という関係になる。
* 「全体 - 部品」の関係。
* 利用する側のクラスは利用される側のクラスのパブリックインターフェイスのみに依存する。
* そのため、利用される側のクラスに変更があっても利用する側のクラスが受ける影響が少ない。
* 依存性を低く・安定したものに保つことができる。
* 継承に比べて書かねばならないコードの量は多くなる。
* 利用する対象のクラスは複数になっても良い。
* 利用する対象のクラスの一部分だけを利用することができる。継承のように不要な部分を含む全体を引き受ける必要がない。

---
# 商品-ノベルティのセットをコンポジションを用いて表現する
以下をそれぞれインスタンスとして必要な数だけ持たせる。

* Item
* Novelty


---
## ノベルティ付き商品セット

<span style="font-size:smaller;">

```
class ItemNoveltySet {
  private $combinationName;
  private $items = [];
  private $novelties = [];

  public function __construct($combinationName, $items, $novelties){
    $this->combinationName = $combinationName;
    $this->items = $items;
    $this->novelties = $novelties;
  }

  public function getCombinationName() {
    return $this->combinationName;
  }

  （つづく）
```

</span>

---

<span style="font-size:smaller;">

```
  （つづき）

  // 各商品名をカンマでつなぐ
  public function getItem() {
    $itemStr = '';
    foreach ($this->items as $item) {
      $itemStr .= $item->getName().', ';
    }
    return $itemStr;
  }

  // 各商品の価格を合計する
  public function getPrice() {
    $price = 0;
    foreach ($this->items as $item) {
      $price += $item->getPrice();
    }
    return $price;
  }

  // 各ノベルティ名を改行でつなぐ
  public function getNovelty() {
    $noveltyStr = '';
    foreach ($this->novelties as $novelty) {
      $noveltyStr .= $novelty->getName().'<br>';
    }
    return $noveltyStr;
  }
}
```

</span>

---
## 各商品セット
### Controller

<span style="font-size:smaller;">

```
$itemSets = [
  new ItemNoveltySet(
    '掛け布団セット',
    [ new Item(['name' => '掛け布団', 'price' => 6000]) ],
    [
      new Novelty('オリジナルボールペン'),
      new Novelty('オリジナルメモ帳'),
    ]
  ),
  new ItemNoveltySet(
    '枕お得セット',
    [
      new Item(['name' => '枕', 'price' => 2500]),
      new Item(['name' => '枕', 'price' => 2500]),
    ],
    [
      new Novelty('特別クーポン券'),
      new Novelty('オリジナルボールペン'),
      new Novelty('オリジナル万年筆'),
      new Novelty('オリジナルメモ帳'),
    ]
  ),
];
```

</span>

---
### View

<span style="font-size:smaller;">


```
foreach ($itemSets as $itemSet) {
  セット名 : <?php echo $itemSet->getCombinationName(); ?><br>
  商品 : <?php echo $item->getItem(); ?><br>
  価格 : <?php echo $item->getPrice(); ?><br>
  ノベルティ : <?php echo $item->getNovelty(); ?><br>
}
```

</span>

---
# 改善点
* 継承ではなくコンポジションを使うことで、商品クラスをより柔軟に拡張することができた。
* コンポジションを用いたクラス「ItemNoveltySet」は、Itemを継承しているわけではないので、Itemクラスの持つ不要なメソッドやプロパティまでは受け継いでいない。つまりそれらの変更に伴う影響を受けない。


---
# 使い分けの判断基準
## 「is a」と「has a」

* A is a B が妥当
  * A-Bが「特殊 - 一般」の関係になる。
  * ゾンビ映画 is a 映画。
  * 継承を使うと良いとされる。
* A has a B が妥当
  * A-Bが「全体 - 部分」の関係になる
  * ゾンビ映画 has a ゾンビ。
  * コンポジションを使うと良いとされる。

---
# 振り返り
### 商品セット is a 商品？  
* 一対一の場合は妥当だと言えたが、商品が複数の組み合わせになることでこの関係からは逸脱していった。
* それでも完全に間違いだとは言いにくい。

### 商品セット has a 商品？  
* こちらの関係は一対一だろうが多対多だろうが妥当だったと言える。


---
# 判断は難しい

* 実際のプロジェクトでは明確な判断材料が必ずしも得られるわけではないので、どちらを使うべきかの判断はむずかしい。
* プロジェクトの現状や今後の展開の予測によって判断する。

---
# 補足 : Decorator パターン
デザインパターンのひとつ「Decorator パターン」がコンポジションを利用している。

---
# Decorator パターン例
## そば・うどん屋のメニュー
* 「そば」または「うどん」を選択し、その上に乗せるトッピングを選ぶことができる。

```
interface Noodle {
  public function getName();
}

class Soba implements Noodle {
  public function getName() { return 'そば'; }
}

class Udon implements Noodle {
  public function getName() { return 'うどん'; }
}
```

---
# 継承を使うと表現しにくい
* 「天ぷらそば/うどん」を継承で表現。

<span style="font-size:smaller;">

```
class TempraSoba extends Soba {
  public function getName() {
    return '天ぷら'.parent::getName();
  }
}

class TempraUdon extends Udon {
  public function getName() {
    return '天ぷら'.parent::getName();
  }
}
```

```
$tempra_soba = new TempraSoba();
echo $tempra_soba->getName();

$tempra_udon = new TempraUdon();
echo $tempra_udon->getName();
```

```
天ぷらそば
天ぷらうどん
```

</span>

---
# コンポジションを使うとスマート
* これが Decorator パターン。
* そば/うどん部分は別インスタンスとして持ち、入れ替え可能。

<span style="font-size:smaller;">

```
class TempraNoodle implements Noodle {
  private $noodle;

  public function __construct(Noodle $noodle) {
    $this->noodle = $noodle;
  }

  public function getName() {
    return '天ぷら'.$this->noodle->getName();
  }
}
```

```
$tempra_soba = new TempraNoodle(new Soba());
echo $tempra_soba->getName();

$tempra_udon = new TempraNoodle(new Udon());
echo $tempra_udon->getName();
```

```
天ぷらそば
天ぷらうどん
```
</span>

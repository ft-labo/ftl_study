# ダックタイピングと<br>ポリモーフィズム（多態性）

---
# ケーススタディ
* 様々な商品を扱うコンビニのような店舗のシステム
* 雑多な商品を一覧表示する

---
## 各商品のクラス

<span style="font-size:smaller;">

```
// 書籍
class Book {
  public function getAuthor() {
    return 'ハワード・フィリップス・ラヴクラフト';
  }
}

// 雑誌
class Magazine {
  public function getEditor() {
    return '洋泉社 映画秘宝編集部';
  }
}

// 野菜
class Vegetable {
  public function getProductionFarmer() {
    return '田中太郎農場（群馬県）';
  }
}

// 惣菜
class Dish {
  public function getCook() {
    return '鈴木鈴子（契約社員）';
  }
}
```

</span>

---
## Controller

```
$items = [
  new Book(),
  new Magazine(),
  new Vegetable(),
  new Dish(),
];
$this->set('items', $items);
```

---

## View

```
<?php foreach ($items as $item) { ?>
  メーカー : 
  <?php if ($item instanceof Book) { ?>
    <?php $item->getAuthor(); ?>

  <?php } else if ($item instanceof Magazine) { ?>
    <?php $item->getEditor(); ?>

  <?php } else if ($item instanceof Vegetable) { ?>
    <?php $item->getProductionFarmer(); ?>

  <?php } else if ($item instanceof Dish) { ?>
    <?php $item->getCook(); ?>

  <?php } ?>
<?php } ?>
```


---
# 問題点
* 各商品は振る舞い（持っているメソッド）が異なるのでViewにおいてクラスを評価して条件分岐させている。
* 新たなクラスが増えると更に条件分岐が増える。

```
// 鮮魚
class Fish {
  public function getFisher() {
    return '海原洋一（青森県八戸漁港）';
  }
}
```

```
<?php if ($item instanceof Fish) { ?>
  <?php $item->getFisher(); ?>
<?php } ?>
```


---
# 改善の取り組み
## メッセージ（要求）に注目する

```
[オブジェクトA] <------- [オブジェクトB]
             (メッセージ）
```

* メッセージとは、「メッセージの送り手」から「メッセージの受け手」に送られる「要求」のこと。

---
# 今回のプログラムでは
* メッセージの送り手 : 商品一覧ページのView
* メッセージの受け手 : 各商品のクラス
* メッセージ : 「その商品を生み出した者」の情報をくれ

↓  
各商品クラスで応答の仕方（メソッド）は異なるが、応えようとしているメッセージは共通している。  
↓  
同一のメッセージ（要求）に応えるなら、メソッドの定義を共通化したい。  
↓  
作り手を返却する「getMaker()」というメソッドをこれらのクラスがそれぞれ持てば良い。

---
# 改善案
## 共通のベースクラスを作って継承を使う

```
abstract class Item {
  protected $maker;
  public function getMaker() {
    return $this->maker;
  }
}

class Book extends Item {
  protected $maker = 'ハワード・フィリップス・ラヴクラフト';
}

（他クラス省略）
```

---
# 継承は自由にはできない
* サンプルでは全部のコードをこちらで書いているから継承も自由にできる。
* しかし、実際の開発においては、フレームワークが用意している指定クラスを継承せざるを得ず、意図した継承を実現できないというケースがある。

---

# 思うように行かない継承制限の例
* 冊子の形をしたものはフレームワークの用意する「Booklet」を継承しなくてはならない
* 食べ物はフレームワークの用意する「Food」を継承しなくてはならない

```
class Book extends Booklet {
class Magazine extends Booklet {
class Vegetable extends Food {
class Dish extends Food {
```

↓  
「Book」「Magazine」「Vegetable」「Dish」に共通のベースクラスを用意してあげることがこちらではできない。

↓  
継承とは違う解決が必要。


---
# 同じメッセージに応答できるという考え方
* ダックタイピング
* ポリモーフィズム（多態性）
* interface の利用

---
# ダックタイピング
* "If it walks like a duck and quacks like a duck, it must be a duck"
* 「アヒルのように歩き、アヒルのように鳴くなら、そりゃアヒルだろう」
* アヒルのように歩き、アヒルのように鳴くのであれば、アヒルであると明記された看板を下げていなくても、それをアヒルであると判断してしまって差し支えない。
* あるクラスが持っているメソッドと同じメソッドを持っているクラスなのであれば、元のクラスと無関係な（継承関係のつながりがない）クラスでもその元のクラスと交換可能なものとして扱ってしまおう、という発想。
* 呼びたいメソッドを一通り持ってるなら、クラスが関係なくてもそれらのオブジェクトは交換可能とみなすこと。

---
# ポリモーフィズム（多態性）
* 多岐にわたるオブジェクトが同じメッセージに応答できる能力のことを指す。
* メッセージの送り手は受け手のクラスを気にする必要がなく、受け手はそれぞれが独自化した振る舞いを提供する。
* メッセージの送り手の視点からみてオブジェクトが置き換え可能。

---

# 発想は同じ
* ダックタイピングもポリモーフィズムも、用語は違うが着眼点は同じ。
* **同じメッセージに応答できるなら交換可能**ということ。
* クラスに制限を課すのではなく振る舞い（メソッド）に制限を課す。

---
# ダックタイピング説明のためのサンプル

```
//アヒル
Class Duck {
  public function walk(): string { /*省略*/ }
  public function quack(): string { /*省略*/ }
}

//突然変異した魚類
Class MutantFish {
  public function walk(): string { /*省略*/ }
  public function quack(): string { /*省略*/ }
  public function destroyWorld(){ /*省略*/ }
}
```

---
## 継承関係がないが同じメソッドを持つ
* 「Duck」と「MutantFish」とは、継承関係もなく、クラス定義上は無関係なクラスである。
* しかしたまたま「walk()」「quack()」という同じ名前・同じスコープ・同じ引数・同じ型の戻り値のメソッドを持っている。
* この時、『「walk()」「quack()」ができるんだったらクラス型はチェックしてないけどまあDuckとみなしてもいいよな』と発想するのがダックタイピング。
* 「同じことをするなら同じものだとみなす」ということ。

---

## ダックタイピング補足
* ダックタイピングとは「同じものであると明記されていないが振る舞いだけから判断して同じものであると推論できる」ということがそもそもの意味。
* なので、後述する「interface」の仕組みを使っていたら厳密には「同じものであると明記している」ことになり、ダックタイピングの枠からは外れることにはなる。
* システム的には「interface が利用できるのに利用しない」ことにはメリットはない。

---
## ふたつのクラスを交換可能とみなして利用

```
//PHP
$ducks = [
  new Duck('リチャード'),
  new Duck('ユーティライネン'),
  new MutantFish('ルシファー'),
  new Duck('花子'),
];

foreach ($ducks as $duck) {
  $duck->walk();
  $duck->quack();
}
```

* 継承関係にあるわけでもない無関係なインスタンスの集合だが、メソッドに問題がないのでエラーにならない。
* クラス型を気にせずメソッド（インターフェイス）さえOKなら問題ないという考え方。

---
# 静的型付け言語ではエラーになる
* アヒルと突然変異魚類のサンプルコードをJavaで書くとエラーになる

```
ArrayList<Duck> ducks = new ArrayList<Duck>();
ducks.add(new Duck('リチャード'));
ducks.add(new Duck('ユーティライネン'));
ducks.add(new MutantFish('ルシファー')); //ここで型違反エラー
ducks.add(new Duck('花子'));

Iterator itr = ducks.iterator();
while(itr.hasNext()){
  itr.walk();
  itr.quack();
  itr.next();
}
```

ArrayList＜Duck＞ というのは、この ArrayList には Duck型のオブジェクト以外の物を入れるのは許さないよ、ただし Duck を継承したサブクラスは許すよ、という制限を意味している。

---
# 言語の特性によるエラー
* Javaは静的型付け言語。クラスの型のチェックが厳密。
* 同じコレクション（ここではArrayList）に異なる型のオブジェクトを入れられない。
* MutantFish は Duck と同じメソッドを持っているからと言ってもクラスとしては継承関係もなく別物なので、ArrayList＜Duck＞の型チェックによって弾かれる。
* PHPのような動的型付け言語では、同じ配列にバラバラな型の値を格納させてもエラーが起きない。

---
# 静的型付け言語で継承が使えないという条件下でポリモーフィズムを利用できないのか
* 複数のクラスに同じ名前・同じ仕様のメソッドをもたせて「同じもの」のように扱いたいのだが、フレームワークの都合上継承が使えない、というケース。
* 静的型付け言語ではポリモーフィズムの工夫を用いることができないのか？

↓  
interface を使えば良い。

---
# interface
* ここでいう「interface」とはプログラム言語が提供する仕組みとしての interface 。
* 「ダックタイピング」や「ポリモーフィズム」をプログラム的に問題なく動くように保証するための仕組み。

## interface が使えない言語も存在する
* 例えば PHP4 では interface がまだ使えるようになっていなかった。PHPにおけるinterfaceの追加は5から。
* interface が使える言語において初めて「クラスの継承関係ではなく振る舞い（メソッドの定義、インターフェイス）によって制限を課す」ということが可能になる。
* interface の仕組みのない言語においても、動的型付け言語なら「ダックタイピング」「ポリモーフィズム」の考えに基づいたコードは書けるが、それが正しく動くかどうかのシステム上の保障はない。

---
# interface の仕組みを用いてサンプルコードを改善


## interface
```
interface MakerGettable {
  public function getMaker(): string;
}
```

---

## 各商品クラス

<span style="font-size:smaller;">

```
class Book extends Booklet implements MakerGettable {
  public function getMaker(): string {
    return 'ハワード・フィリップス・ラヴクラフト';
  }
}

class Magazine extends Booklet implements MakerGettable {
  public function getMaker(): string {
    return '洋泉社 映画秘宝編集部';
  }
}

class Vegetable extends Food implements MakerGettable {
  public function getMaker(): string {
    return '田中太郎農場（群馬県）';
  }
}

class Dish extends Food implements MakerGettable {
  public function getMaker(): string {
    return '鈴木鈴子（契約社員）';
  }
}

```

</span>

---
## Controller

```
$items = [
  new Book(),
  new Magazine(),
  new Vegetable(),
  new Dish(),
];
$this->set('items', $items);
```

## View

```
<?php foreach ($items as $item) { ?>
  メーカー : <?php $item->getMaker(); ?>
<?php } ?>
```

↓  
MakerGettable インターフェイスによって getMaker() メソッドを持っているということがシステム的に保証されている。

---
# interface を使えば静的型付け言語でもポリモーフィズムの工夫を利用できる

```
ArrayList<MakerGettable> items
  = new ArrayList<MakerGettable>();

ducks.add(new Book());
ducks.add(new Magazine());
ducks.add(new Vegetable());
ducks.add(new Dish());

Iterator itr = ducks.iterator();
while(itr.hasNext()){
  itr.getMaker();
  itr.next();
}
```

* ArrayList の内容の制限を MakerGettable インターフェイスにすることで、継承関係にはない複数のクラスを同じもの（いわばアヒル）として扱えるようになった。

---
# 改善点
* メッセージ（要求）に注目し、interface を統一することで複数のクラスに同じ振る舞いをさせることができるようになった。
* その結果、Viewでの処理が減った。
* 今後、商品クラスの種類が増えても同じ interface を守れば View はコードを変更せずに処理することができる。

↓  
「ダックタイピング」「ポリモーフィズム（多態性）」の考え方に基づき interface を利用することで、より「変更の容易」なプログラムになったと言える。

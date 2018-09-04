# 継承

---
# 継承とは
* 継承とは、あるオブジェクトが受け取ったメッセージを別のオブジェクトに委譲する、という関係を2つのオブジェクトの間で結ぶこと。
* メッセージの自動委譲によるコードの共通化を実現する。

## メッセージの自動委譲
* メッセージへの応答を、受け取ったオブジェクト自身が直接行うのか、他のオブジェクトに委譲するのか、その関係設定を自動で行うこと。

<span style="font-size:smaller;">

```
[メッセージの送り手]----->[具象クラス]----->[抽象クラス]
            メッセージ（要求）   メッセージの移譲（丸投げ）
```

</span>

---
# 継承のメリットとデメリット
## メリット
* 複数のクラスの共通の処理をまとめ、メソッドの再利用性を高める。

## デメリット
* クラスが増えるので、作成とメンテナンスのコストが掛かる。
* メソッドの記述箇所が分散し、プログラムがわかりにくくなる。
  * あるクラスのインスタンスが呼び出しているメソッドの処理を調査したいが、該当のメソッドがそのクラス自体には記述されておらず、いくつも継承関係を遡らないとメソッドの記述箇所が見つからないというケースがある。

---
# ケーススタディ
* お菓子専門店のWebサイト。
* 各お菓子を継承を使ったクラスで表現したい。
* Webページにお菓子の詳細や一覧を表示する。

---
# サンプルプログラム

## 抽象クラス

<span style="font-size:smaller;">

```
// 商品
abstract class Item {
  public function __construct($name, $price){ /*省略*/ }
  public function getName(){ /*省略*/ }
  public function getPrice(){ /*省略*/ }
}

abstract class Sweet extends Item {} // お菓子

abstract class Gum extends Sweet {} // ガム
abstract class Chocolate extends Sweet {} // チョコレート
abstract class Candy extends Sweet {} // キャンディ
abstract class Doughnut extends Sweet {} // ドーナツ
abstract class PotatoChips extends Sweet {} // ポテトチップス
```

</span>

---
## 具象クラス

<span style="font-size:smaller;">

```
// 怪獣ガム
class KaijuGum extends Gum {
  public function __construct(){
    parent::__construct('復刻版怪獣ガム', 520);
  }

  public function getToy(){ return 'ゴジラ（1954年版）フィギュア'; }
}

// 生チョコレート
class RawChocolate extends Chocolate {
  public function __construct(){
    parent::__construct('高級風生チョコ', 800);
  }

  public function expireAt(){ return '2018-09-05'; }
}

// 軍艦キャンディ
class WarshipCandy extends Candy {
  public function __construct(){
    parent::__construct('空想軍艦パート3', 700);
  }

  public function getToy(){ return '宇宙駆逐艦いなづま'; }
}
```

</span>

---
## 具象クラスつづき

<span style="font-size:smaller;">

```
// 寿司ドーナツ
class SushiDoughnut extends Doughnut {
  public function __construct(){
    parent::__construct('奇跡のスシドー', 200);
  }
}

// バーチャルユーチューバーチップス
class VirtualYoutuberChips extends PotatoChips {
  public function __construct(){
    parent::__construct('バーチューバーチップス', 63);
  }

  public function getToy(){
    return 'バーチューバーカード（全5種類）';
  }

  public function expireAt(){
    return '2018-10-05';
  }
}
```

</span>

---

## Controller

```
$kaiju_gum = new KaijuGum();
$raw_chocolate = new RawChocolate();
$warship_candy = new WarshipCandy();
$sushi_doughnut = new SushiDoughnut();
$virtual_youtuber_chips = new VirtualYoutuberChips();
```

---

## View

<span style="font-size:smaller;">

```
<p>
  商品名 : <?php $kaiju_gum->getName(); ?><br>
  価格 : <?php $kaiju_gum->getPrice(); ?><br>
  おまけ : <?php $kaiju_gum->getToy(); ?><br>
</p>
<p>
  商品名 : <?php $raw_chocolate->getName(); ?><br>
  価格 : <?php $raw_chocolate->getPrice(); ?><br>
  消費期限 : <?php $raw_chocolate->expireAt(); ?><br>
</p>
<p>
  商品名 : <?php $warship_candy->getName(); ?><br>
  価格 : <?php $warship_candy->getPrice(); ?><br>
  おまけ : <?php $warship_candy->getToy(); ?><br>
</p>
<p>
  商品名 : <?php $sushi_doughnut->getName(); ?><br>
  価格 : <?php $sushi_doughnut->getPrice(); ?><br>
</p>
<p>
  商品名 : <?php $virtual_youtuber_chips->getName(); ?><br>
  価格 : <?php $virtual_youtuber_chips->getPrice(); ?><br>
  おまけ : <?php $virtual_youtuber_chips->getToy(); ?><br>
  消費期限 : <?php $virtual_youtuber_chips->expireAt(); ?><br>
</p>
```

</span>


---
# 問題点
* わざわざ作ってあるスーパークラスだがメソッドを持ってないものが多い。不要である。
* 同じメソッドを複数のクラスが持っていて共通化されていない。

# 反省点
* 抽象クラスと継承ありきで作り始めている。
* 継承を使っているのに肝心の「コードの共通化」ができてないということは継承の設計が間違っている。
* 「ガム」「キャンディ」といったお菓子の種類に従って継承を作っているが、どうもこの発想は適切ではないらしい。


---
# 解説の前に用語解説

<dl>
<dt>抽象クラス</dt><dd>継承されて利用されるためのクラス。「abstract class」。<br>それ自体はインスタンス化されない。</dd>
<dt>具象クラス</dt><dd>それ自体のインスタンスが利用されるクラス。</dd>
<dt>スーパークラス</dt><dd>継承関係で親となるクラス。<br>「class Sub extends Super」の場合、Super。</dd>
<dt>サブクラス</dt><dd>継承関係で子となるクラス。<br>「class Sub extends Super」の場合、Sub。</dd>
</dl>

抽象クラス ≒ スーパークラス  
具象クラス ≒ サブクラス

---
# 継承を利用する際の原則
### 具象クラスから始める
* いきなり抽象クラスから書き始めない。
* その抽象クラスが結局不要に終わったというケースを避けるため。

### 必要なメソッド・プロパティのみ引き上げる
* 複数の具象クラスが同一のメッセージに応答する同一のメソッドを持っている場合、スーパークラスへの引き上げ検討対象になる。

### 「スーパークラス-サブクラス」の関係が「一般-特殊」の関係になっていること
* サブクラスはスーパークラスのすべてであり、かつスーパークラスを上回るもの。
* スーパークラスを特化したものがサブクラス。

---
# サンプルプログラムの改善
* 継承関係を整理したい。
* メソッドは、まずメッセージ（求められている要求）があった上でそれに応えるために作られるべきものなので、重要なのは「メッセージ（要求）」を把握すること。
* ということはまず目を向けるべきは個々のお菓子クラスではなく、それを呼び出している箇所。
* 今回のサンプルではView。

---
# メッセージの抽出

### 全お菓子へのメッセージ
* 商品名をくれ
* 価格をくれ

### 一部のお菓子へのメッセージ
* おまけをくれ
* 消費期限をくれ

↓  
この要求にスマートに答えられるようにクラスの継承関係が作られていれば良さそう。

---
# お菓子クラス改善への取り組み
* スタート視点として、継承を使わず具象クラスから始める。

<span style="font-size:smaller;">

```
// 怪獣ガム
class KaijuGum {
  public function getName(){ return '復刻版怪獣ガム'; }
  public function getPrice(){ return 520; }
  public function getToy(){ return 'ゴジラ（1954年版）フィギュア'; }
}

// 生チョコレート
class RawChocolate {
  public function getName(){ return '高級風生チョコ'; }
  public function getPrice(){ return 800; }
  public function expireAt(){ return '2018-09-05'; }
}
```

</span>

---

<span style="font-size:smaller;">

```
// 軍艦キャンディ
class WarshipCandy {
  public function getName(){ return '空想軍艦パート3'; }
  public function getPrice(){ return 700; }
  public function getToy(){ return '宇宙駆逐艦いなづま'; }
}

// 寿司ドーナツ
class SushiDoughnut {
  public function getName(){ return '奇跡のスシドー'; }
  public function getPrice(){ return 200; }
}

// バーチャルユーチューバーチップス
class VirtualYoutuberChips {
  public function getName(){ return 'バーチューバーチップス'; }
  public function getPrice(){ return 63; }
  public function getToy(){ return 'バーチューバーカード（全5種類）'; }
  public function expireAt(){ return '2018-10-05'; }
}
```

</span>

---
# 第一の引き上げ
* `getName()`と`getPrice()`とは全お菓子クラスが持っている。
* `getName()`と`getPrice()`とを持った抽象クラスを作ってはどうか。
* 「一般-特殊」の関係になるようなスーパークラスの名付けを考える。

---
# 適切なスーパークラスの吟味

### 案 : Furniture（家具）
* 明らかに悪い例として。
* 「家具-寿司ドーナツ」は「一般-特殊」の関係になっていない。「家具」という概念は「お菓子」を含まない。
* 例えば仮に既に`getName()`と`getPrice()`とを持っているFurnitureクラスが作られていたとして、「これメソッドがちょうどいいから継承元にしちゃえばいいじゃん」みたいなケースがあるかもしれないが、そういうヘンテコな継承をすると後々問題の原因となりやすい。

---
# 適切なスーパークラスの吟味つづき

### 案 : Toy（おもちゃ）
* 「おもちゃ-怪獣ガム」なら「一般-特殊」の関係になる。
* 「おもちゃ-寿司ドーナツ」では「一般-特殊」の関係にならない。
* おもちゃ専門店のWebサイトで扱う商品の大半がおもちゃなのであればスーパークラス候補として「おもちゃ」は妥当だろうが、お菓子専門店では使いにくいスーパークラスになりそう。

---
# 適切なスーパークラスの吟味つづき

### 案 : Item（商品）
* 「商品-寿司ドーナツ」は「一般-特殊」の関係にはなっている。
* お菓子以外にも取扱商品があり、それらも包括するのなら「商品」で妥当な気はする。
* 今回の店舗はお菓子専門店の想定なので、「商品」というくくりでは大きすぎる気がする。

### 案 : Sweet（お菓子）
* 「商品-寿司ドーナツ」は「一般-特殊」の関係にはなっている。
* 今回の店舗はお菓子専門店の想定なので、「お菓子」というくくりでちょうど良さそうだと判断しておく。

---
# サンプルプログラム改善

## 抽象クラス

<span style="font-size:smaller;">

```
// お菓子
abstract class Sweet {
  public function __construct($name, $price){ /* 省略 */ }
  public function getName(){ /* 省略 */ }
  public function getPrice(){ /* 省略 */ }
}
```

</span>

---
# 第二の引き上げ
* `getToy()`を持ったクラスが複数ある。5クラス中　3クラス。
* `expireAt()`を持ったクラスが複数ある。5クラス中　2クラス。
* `getToy()`と`expireAt()`とを同時に持ったクラスもひとつある。  

↓  
* どれをどう引き上げるべきか。
* 今後の変更をどう予測するか。

---
# コスパを考える
* 継承を使うかどうかの判断のポイントはコスパ。
* スーパークラスを新たに作ったりメソッドを移動させたりするのにもコストがかかる。

---
# コストに見合わないケース
* 作ったメソッドが再利用性が高そうに感じたのでスーパークラスを作って共通化しておいたが、結局サブクラスはひとつだけで終わってスーパークラスをサブクラスに統合するはめになった。
* 共通の処理を持っているクラスが複数あったのでスーパークラスを新たに作って共通メソッドに引き上げたが、仕様がまだ固まっておらず結局それぞれのメソッドが別物となり、メソッドをそれぞれサブクラスに戻すことになった。
* わざわざスーパークラスを追加したが、引き上げたメソッドがごく簡単な内容の1メソッドだけ・それを使うサブクラスがふたつだけと、共通化して得られるアドヴァンテージが僅かだった。

---
# みっつ来たら引き上げる
* ひとつのサブクラスしか持たないスーパークラスは無意味。
* スーパークラスにまとめる判断のタイミングは「3種類のクラスが出てきたとき」が目安になる。
* みっつくらい出れば要件が固まっている。

## ふたつだと判断に迷うが
* 3つ目の登場する確率が高いなら引き上げてもいい。
* 共通するメソッドがそれぞれ別々の仕様に分かれる可能性が高いなら引き上げないでおく。
* 共通するメソッドへの変更頻度が高く、そのふたつのメソッドを同時に修正しているということが多いなら、引き上げて共通化するのにメリットがある。

---
# この時点での判断
### getToy() は引き上げる
* `getToy()`を持ったクラスは3つある。

### expireAt() は現時点では見送る
* `expireAt()`を持ったクラスはまだふたつ。
* 「寿司ドーナツ」は現状では消費期限を表示してないがいかにも消費期限が短そう。
* 考えてみればそもそも全てのお菓子が消費期限を持っているはず。
* なんらかの変更が発生しそうだと予測できる。
* なので、現時点では下手にメソッドを動かさず、具象クラスがそれぞれメソッドを持っている状態のままにしておく。

---
# サンプルプログラム改善

## 抽象クラス

<span style="font-size:smaller;">

```
// お菓子
abstract class Sweet {
  public function __construct($name, $price){
    $this->name = $name;
    $this->price = $price;
  }
  public function getName(){ /*省略*/ }
  public function getPrice(){ /*省略*/ }
}

// 玩具菓子
abstract class SweetWithToy extends Sweet {
  public function __construct($name, $price, $toy){
    parent::__construct($name, $price);
    $this->toy = $toy;
  }
  public function getToy(){ /*省略*/ }
}
```

</span>

---
## 具象クラス

<span style="font-size:smaller;">

```
// 怪獣ガム
class KaijuGum extends SweetWithToy {
  public function __construct(){
    parent::__construct(
      '復刻版怪獣ガム', 520, 'ゴジラ（1954年版）フィギュア');
  }
}

// 生チョコレート
class RawChocolate extends Sweet {
  public function __construct(){
    parent::__construct('高級風生チョコ', 800);
  }
  public function expireAt(){
    return '2018-09-05';
  }
}

// 軍艦キャンディ
class WarshipCandy extends SweetWithToy {
  public function __construct(){
    parent::__construct('空想軍艦パート3', 700, '宇宙駆逐艦いなづま');
  }
}
```

</span>

---
## 具象クラスつづき

<span style="font-size:smaller;">

```

// 寿司ドーナツ
class SushiDoughnut extends Sweet {
  public function __construct(){
    parent::__construct('奇跡のスシドー', 200);
  }
}

// バーチャルユーチューバーチップス
class VirtualYoutuberChips extends SweetWithToy {
  public function __construct(){
    parent::__construct(
      'バーチューバーチップス', 63, 'バーチューバーカード（全5種類）');
  }
  public function expireAt(){
    return '2018-10-05';
  }
}
```

</span>


---
# 改善点
* 複数のクラスが持つ同一の処理`getToy()`が共通化され、一箇所で管理されるようになった。
* メソッドを持たない無駄な抽象クラスがなくなった。
* `getToy()`を使わないクラスはそのメソッドにアクセスできないようになっている。

↓  
`getName()` `getPrice()` `getToy()` に変更がある場合、修正箇所が一箇所で済むようになり、より「変更が容易」になったと言える。

---
# 注意点
継承を利用するにあたって呼び込みがちなリスクについて。

---
## 過剰な共通化
* スーパークラスにメソッドを引き上げて共通化することで再利用性が高まる。
* 高すぎる再利用性はデメリットとなる。
  * 本来の意図から外れたサブクラスからメソッドが利用され、原因の追いにくいバグの原因となる可能性が増える。
* メソッドをスーパークラスに引き上げた結果、そのメソッドを必要としないサブクラスにまで利用範囲が広がってしまう場合、抽象の設計が適切でないと考えられる。

---
## スーパークラスとサブクラスとの間で起こる密結合
* スーパークラスとサブクラスとの間でも、一般的な法則と同様に、依存性が高いことはリスクになる。
* サブクラスがスーパークラスの処理を呼び出す時（言語によって`super`や`parent`を用いる）、スーパークラスの処理の詳細を知っているということであり、依存している。
* 依存性が高くなると変更に弱くなる。

---
## 今回のケースを振り返り
* 仮に`getToy()`をSweetクラスに持たせていた場合、おまけを持たない「寿司ドーナツ」などのクラスにまで利用範囲が広がってしまい、不適切だっただろうと考えられる。
* 今回のケースでは、具象クラスは抽象クラスのコンストラクタを利用している。
* つまり、「サブクラスはスーパークラスに依存している」。
* SweetクラスやSweetWithToyクラスのコンストラクタに変更があった場合、各お菓子クラスに修正が必要になるという弱点はある。

---
# さらなる学び - 参考

## コンポジション
* 継承と同じようなケースにおいて継承の代わりに採用できる手法。
* 機能を受け継ぎたいクラスのインスタンスをプロパティとして持たせる。
* 「継承よりコンポジション」と言われるほど、拡張性や安定性に優れる。
* 継承よりもコード量は多くなる。
* [別ドキュメント参照「コンポジション」](./composition.md)

## テンプレートメソッドパターン
* デザインパターン（オブジェクト設計において定石となる手法をパターン化したもの）のひとつ。
* 継承の仕組みを上手く利用して「具象クラスには固有の部分だけ持たせる」という手法。
* [別ドキュメント参照「テンプレートメソッドパターン」](./template_method_pattern.md)

## ダックタイピング
* 「同じメッセージに応答することができるが継承関係は持たせられない」という場合に、「クラスを横断して共通するメソッド」を利用する手法。
* [別ドキュメント参照「ダックタイピングとポリモーフィズム」](./duck_typing_polymorphism.md)

# インターフェイス
* 講義実施者 : 石井 尊
* 講義実施日 : 2018-09-28

---
# ここで言う「インターフェイス」とは
* ここで言う「インターフェイス」とはプログラム言語の提供する「interface」の仕組みのことではなく、「メソッドの名前・引数・戻り値・スコープ」といった「メソッドの仕様」のこと。
* 「interface」という言葉のそもそもの意味は、「ある二者の間の接触面＝やり取りの窓口」ということ。
* プログラムの世界ではオブジェクトとオブジェクトとがやりとりをする時メソッドを利用するので、「インターフェイス＝メソッドの仕様」という意味合いになる。

---
# 開くべきメソッドと隠蔽するべきメソッド
* クラスはメソッドを通して他のクラスとの関係を持つ。
* 開くべきメソッドと隠蔽するべきメソッドとがある。
* 「実装の詳細」は隠蔽するべき。

---
# ケーススタディ
* Webサイトのアクセスカウンタ。
* 環境によってファイルに書き込んだりデータベースに書き込んだり使い分けしたい。
* トップページを経ないで直接コンテンツページに来る人が多いらしいので、カウンター表示とカウントアップとはトップページとコンテンツページの両方で行う。

---
# サンプルプログラム

### アクセスカウンタークラス

<span style="font-size:smaller;">

```
class AccessCounter {
  // 現在のアクセス数を取得
  public function getTotalCount(bool $is_use_db){
    if ($is_use_db) {
      $this->getTotalCountFromDb();
    } else {
      $this->getTotalCountFromFile();
    }
  }
  // アクセス数を更新
  public function increment(bool $is_use_db){
    if ($is_use_db) {
      $this->incrementWithDb();
    } else {
      $this->incrementWithFile();
    }
  }
  // すべてのアクセス修飾子が public
  public function getTotalCountFromDb(){ /*省略*/ }
  public function getTotalCountFromFile(){ /*省略*/ }
  public function incrementWithDb(){ /*省略*/ }
  public function incrementWithFile(){ /*省略*/ }
}
```

</span>

---
## 呼び出し側

### トップページのController

<span style="font-size:smaller;">

```
$access_counter = new AccessCounter();

if ($env == 'product') {
  $is_use_db = true;
} else {
  $is_use_db = false;
}

$total_count = $access_counter->getTotalCount($is_use_db);
$access_counter->increment($is_use_db);
```

</span>

### コンテンツページのController

<span style="font-size:smaller;">

```
$access_counter = new AccessCounter();

if ($env == 'product') {
  $total_count = $access_counter->getTotalCountFromDb();
  $access_counter->incrementWithDb();
} else {
  $total_count = $access_counter->getTotalCountFromFile();
  $access_counter->incrementWithFile();
}
```

</span>


---
# 変更シミュレーション
* redis （キーバリューストアの仕組み）も使えるようにしたい。

<span style="font-size:smaller;">

```
class AccessCounter {
  public function getTotalCount(string $mode){
    if ($mode == 'db') {
      $this->getTotalCountFromDb();
    } else
    if ($mode == 'file') {
      $this->getTotalCountFromFile();
    } else
    if ($mode == 'redis') {
      $this->getTotalCountFromRedis();
    }
  }
  public function increment(string $mode){
    if ($mode == 'db') {
      $this->incrementWithDb();
    } else
    if ($mode == 'file') {
      $this->incrementWithFile();
    } else
    if ($mode == 'redis') {
      $this->incrementWithRedis();
    }
  }
  （続く）
```

</span>

---

<span style="font-size:smaller;">

```
  （続き）
  public function getTotalCountFromDb(){ /*省略*/ }
  public function getTotalCountFromFile(){ /*省略*/ }
  public function getTotalCountFromRedis(){ /*省略*/ }

  public function incrementWithDb(){ /*省略*/ }
  public function incrementWithFile(){ /*省略*/ }
  public function incrementWithRedis(){ /*省略*/ }
}
```

</span>

---
## 呼び出し側

### トップページのController

<span style="font-size:smaller;">

```
$access_counter = new AccessCounter();

if ($env == 'product') {
  $mode = 'db';
} else
if ($env == 'staging') {
  $mode = 'redis';
} else {
  $mode = 'file';
}

$total_count = $access_counter->getTotalCount($mode);
$access_counter->increment($mode);
```

</span>

---
### コンテンツページのController

<span style="font-size:smaller;">

```
$access_counter = new AccessCounter();

if ($env == 'product') {
  $total_count = $access_counter->getTotalCountFromDb();
  $access_counter->incrementWithDb();
} else
if ($env == 'staging') {
  $total_count = $access_counter->getTotalCountFromRedis();
  $access_counter->incrementWithRedis();
} else  {
  $total_count = $access_counter->getTotalCountFromFile();
  $access_counter->incrementWithFile();
}
```

</span>

---
# 問題点
* 「アクセスカウンターを実現する仕組みをDBにするかファイルにするかRedisにするか」という、Controllerには無関係な理由による変更によってControllerまで修正を余儀なくされている。
* 同じことができるパブリックメソッドが複数あり、呼び出し元がそれぞれ別々のメソッドを利用しており、修正の際もそれぞれ別々の修正内容になっている。

---
# 改善のための着眼点
## Controller から AccessCounter へのメッセージ（要求）は以下のふたつ
* 現在のアクセス数を教えてほしい。
* アクセスカウンターのカウントをひとつ増やしてほしい。

## 以下は Controller の立場にとってはどうでもいいため、Controller から AccessCounter へのメッセージではない
* データベースを使ってほしい。
* ファイルを読み書きしてほしい。
* Redisを使ってほしい。

---
# パブリックインターフェイスとプライベートインターフェイス
* パブリック : 他クラスとやり取りする窓口。高い安定性を保証すべき。
* プライベート : 処理の詳細に関わり、他者からは隠蔽されているべき。

---
# パブリックインターフェイス
* そのクラスが持つ、公開されているメソッドの仕様。
* アクセス修飾子は「public」。
* どんなクラスからも利用することができる。
* 通常、「インターフェイス」というとこちらの意味になる。
* 他者とやり取りするために持っている窓口。
* ここでは言語の持っている仕組みとしての interface で定義しているということでは必ずしもない。
* 他者に対する「説明の責任」とも言える。
* 他者から依存されることを前提にして開く窓口であり、変更が最小限になるべき。
* きちんとテストコードが書かれてその動作の安定が保証されているべき。

---
# プライベートインターフェイス
* あるクラス自身が内部的に利用するメソッドの仕様のこと。
* ここでは言語の用意する仕組みの「interface」のことではない。
* アクセス修飾子は「private」または「protected」。
* 二者間（自分と他者）でやり取りするわけではないので本来の意味の「インターフェイス」性は薄い。
* 通常、「インターフェイス」という言葉でこちらを指すことはない。
* 実装の詳細に関わり、他のクラスからは隠蔽されているべき。
* 実装の仕方の都合で頻繁に変更される。
* テストコードで細かくチェックすることはあまりない。

---
# パブリックインターフェイスとプライベートインターフェイスの使い分け

## パブリック
* 最も良い面、最も安定している面、相手が必要としている面だけを見せる。
* 他者から見えるインターフェイスは必要最小限であるべき。
* 実装の詳細に関わる情報を引数にとるべきではない。
* 他者から依存されることを前提とする。

## プライベート
* 実装の詳細について知っている。
* 実装の詳細に関わる情報を引数にとっても良い。
* 他者をプライベートインターフェイスに依存させるべきではない。
* 他者が知らなくていいことは隠蔽されているべき。

---
# 「開きすぎているクラス」とはなにか
* 他クラスに対しては隠蔽すべきであるような実装の詳細にタッチするメソッドを public として公開してしまっているもの。

## 「プライベートインターフェイスに依存させる」とはなにか
* 本来 public にするべきではないような実装の詳細に関わるメソッドを public にし、その利用を他のクラスに強要すること。
* アンチパターン（＝やるべきではない悪い例）である。

---
# サンプルプログラム振り返り
* アクセスカウンタークラスのパブリックインターフェイスは「実装の詳細」についての引数を取っており、自分を呼び出す他者に対して自分が行う処理の詳細についての知識を持つことを強制している。
* つまり、「開きすぎたクラス」であり、「プライベートインターフェイスに依存させ」ており、「依存性を高めて」いる。
* インターフェイスを見直し、パブリックにするべきものとプライベートにするべきものとを分別する。

---
# 改善サンプル

### アクセスカウンタークラス

<span style="font-size:smaller;">

```
class AccessCounter {
  private $mode;
  public function __construct() {
    $env = /* 設定ファイルから設定を取得する処理 */;
    switch($env){
      case ('product'): $this->mode = 'db'; break;
      case ('staging'): $this->mode = 'redis'; break;
      default: $this->mode = 'file'; break;
    }
  }

  // 現在のアクセス数を取得
  public function getTotalCount(){
    if ($this->mode == 'db') {
      $this->getTotalCountFromDb();
    } else
    if ($this->mode == 'file') {
      $this->getTotalCountFromFile();
    } else
    if ($this->mode == 'redis') {
      $this->getTotalCountFromRedis();
    }
  }
  （続く）
```

</span>

---

<span style="font-size:smaller;">

```
  （続き）

  // アクセス数を更新
  public function increment(){
    if ($this->mode == 'db') {
      $this->incrementWithDb();
    } else
    if ($this->mode == 'file') {
      $this->incrementWithFile();
    } else
    if ($this->mode == 'redis') {
      $this->incrementWithRedis();
    }
  }

  private function getTotalCountFromDb(){ /*省略*/ }
  private function getTotalCountFromFile(){ /*省略*/ }
  private function getTotalCountFromRedis(){ /*省略*/ }

  private function incrementWithDb(){ /*省略*/ }
  private function incrementWithFile(){ /*省略*/ }
  private function incrementWithRedis(){ /*省略*/ }
}
```

</span>

---
## 呼び出し側
* パブリックメソッドが限定されたので呼び出し方が統一された。

### トップページのController / コンテンツページのController

```
$access_counter = new AccessCounter();
$total_count = $access_counter->getTotalCount();
$access_counter->increment();
```

---
# 改善点
* パブリックインターフェイスが「getTotalCount()」「increment()」のふたつに限定され、「同じことをしようとしている呼び出し元が別々の呼び出し方をしている」というケースがなくなった。
* 「DB、ファイル、Redisのどれを使うか」という実装の詳細について、呼び出し側のControllerが意識する必要がなくなった。
* その結果、アクセスカウンターの実装の詳細が変更になってもControllerからの呼び出し箇所には変更が不要になった。

↓  
実装の詳細は private 化して隠蔽し、public なメソッドを必要最小限になるようにしたことで、実装の詳細の変更による呼び出し元への影響をなくし、より「変更に強く」なったと言える。

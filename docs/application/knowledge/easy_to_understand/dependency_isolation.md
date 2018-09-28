# 依存の隔離
* 講義実施者 : 石井 尊
* 講義実施日 : 2018-09-28

---
# 依存の隔離とは
* 依存関係をなくす事ができない外部クラスに対しては、依存部分を隔離するという手法。
* 依存関係がわかりやすくなる。
* 依存先の外部クラスが原因となる変更による影響範囲を限定させることができる。

---
# ケーススタディ
* オンラインゲームでガチャの処理を担うクラス
* デリケートな問い合わせが頻繁に来るので何かとログを取るようにしたい
* ログを取るのはフレームワークの持っているLogクラスを使う

---
# サンプルコード

<span style="font-size:smaller;">

```
class Gacha {
  private $user_id;
  public function __construct(int $user_id){ /*省略*/ }

  public function single(bool $is_use_ticket){
    // 単発ガチャ処理（省略）

    $log = new Log();
    $log->info([
      'user_id' => $this->user_id,
      'is_use_ticket' => $is_use_ticket,
      'type' => 1,
    ]);
  }

  public function ten(bool $is_use_ticket){
    // 10連ガチャ処理（省略）

    $log = new Log();
    $log->info([
      'user_id' => $this->user_id,
      'is_use_ticket' => $is_use_ticket,
      'type' => 10,
    ]);
  }
}
```

</span>


---
# 変更シミュレーション
* フレームワークの Log ではなく、クラウドのログ記録APIを使うことになった。
* クラウド業者の提供するライブラリの CloudLog クラスを使う必要がある。
* Log クラスのログ記録メソッドと CloudLog クラスのログ記録メソッドとは引数の仕様が異なる。

---
# コード修正

<span style="font-size:smaller;">

```
  public function single(bool $is_use_ticket){
    // 単発ガチャ処理（省略）
    // 変更箇所
    $cloud_log = new CloudLog();
    $cloud_log->send(
      'info',
      [
        'user_id' => $this->user_id,
        'is_use_ticket' => $is_use_ticket,
        'type' => 1,
      ]
    );
  }

  public function ten(bool $is_use_ticket){
    // 10連ガチャ処理（省略）
    // 変更箇所
    $cloud_log = new CloudLog();
    $cloud_log->send(
      'info',
      [
        'user_id' => $this->user_id,
        'is_use_ticket' => $is_use_ticket,
        'type' => 10,
      ]
    );
  }
```

</span>

---
# 問題点
* 外部クラスの都合による変更のために複数の箇所に修正が必要になっている。
* 繰り返しが多い。
* GachaクラスのからCloudLogクラスへの依存度が高い。

---
# 改善の工夫
* 依存先である外部クラスを利用する箇所はそれだけを行うメソッドに切り出して隔離する。

## インスタンス変数の作成の隔離
* 隔離されたことにより、依存していることが公然となる。

## 外部クラスのメソッドを隔離
* 外部クラスのメソッドの仕様が変わるたび、その使用箇所で機能が壊される。
* そこで、外部クラスのメソッドをラッパーメソッドに隔離して変更により壊される箇所を集約する。
* DRYの原則であればある処理が2箇所以上で使われたときはじめて行うべきだが、変更の可能性が高いならばあらかじめ隔離しておくことで保険になる。

---
# 改善サンプルコード

<span style="font-size:smaller;">

```
class Gacha {
  private $user_id;
  private $logger;

  public function __construct(int $user_id){
    $this->user_id = $user_id;
    $this->logger = $this->prepareLogger();
  }

  // インスタンス変数の作成の隔離
  private function prepareLogger() {
    return new CloudLog();
  }

  // 外部クラスのメソッドを隔離
  private function log($is_use_ticket, $type) {
    $params_array = [
      'user_id' => $this->user_id,
      'is_use_ticket' => $is_use_ticket,
      'type' => $type,
    ];

    $this->logger->send('info', $params_array);
  }


  （続く）
```

</span>

---


```
  （続き）


  public function single(bool $is_use_ticket){
    // 単発ガチャ処理（省略）
    $this->log($is_use_ticket, 1);
  }

  public function ten(bool $is_use_ticket){
    // 10連ガチャ処理（省略）
    $this->log($is_use_ticket, 10);
  }
}
```

---
# 改善点

### インスタンス変数の作成の隔離
* Gachaクラスからログクラスへの依存を減らすことはできないが、prepareLogger() メソッドによって「CloudLog」に依存しているんだなということが一目瞭然になった。

### メソッドへの隔離
* 実際にログを書き込む処理を log() メソッドに隔離することで、ログ書き込み処理の仕様が変わっても修正すべきメソッドがその一箇所のみになる。


---
# 追加変更シミュレーション
* 環境ごとにログのとり方を変えたいということになった。
* 本番環境では CloudLog クラスを使う。
* 開発環境では Log クラスを使う。


---
# サンプルコード

<span style="font-size:smaller;">

```
  // インスタンス変数の作成の隔離
  private function prepareLogger() {
    if (/* 本番環境である */) {
      return new CloudLog();
    } else {
      return new Log();
    }
  }

  // 外部クラスのメソッドを隔離
  private function log($is_use_ticket, $type) {
    $params_array = [
      'user_id' => $this->user_id,
      'is_use_ticket' => $is_use_ticket,
      'type' => $type,
    ];

    if ($this->logger instanceof CloudLog) {
      $this->logger->send('info', $params_array);
    } else {
      $this->logger->info($params_array);
    }
  }
```

</span>

---
# 改善点
* 変更箇所が「インスタンスの作成」「ログの記録実行」のそれぞれ一箇所に集約されている。

↓  
外部クラスの利用箇所を独立したメソッドに隔離することで依存関係がわかりやすくなり、依存先のクラスの変更による修正箇所が限定され、より「変更が容易」になったと言える。


<span style="font-size:smaller; color:gray;">
※「CloudLog」と「Log」との両方の役割を持ち環境ごとに振る舞いを変える新たなクラス（たとえば「CustomLog」クラスというような）を作るという方法も考えられるが、今回のテーマからは外れてくるのでサンプルコードは示さない。
</span>

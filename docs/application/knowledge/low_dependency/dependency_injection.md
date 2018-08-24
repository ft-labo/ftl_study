# 依存オブジェクトの注入<br>（Dependency Injection）

---
# ケーススタディ
* データベースメンテナンスのタスク処理。
* データベース全体を走査し、不要なゴミデータを削除するという定期自動実行処理がある。
* 実行の開始時刻と終了時刻と実行結果とをログに保存しておきたい。
* PHPUnitテストを書いておきたい。

---
## 定期処理自動実行クラス
```
class DatabaseMaintenanceTask {
  public function run() {
    //現在時刻をログに書き込む処理

    $db_maintainer = new DbMaintainer();
    $result = $db_maintainer->executeMaintenance();

    //処理結果をログに書き込む処理
    //現在時刻をログに書き込む処理
  }
}
```

---
## データベースメンテナンス実行クラス
```
class DbMaintainer {
  public function executeMaintenance(): string {
    // 重くて複雑な処理
    return $result_massage;
  }
}
```

## テストコード
* テストしたいのは DatabaseMaintenanceTask::run()

```
class DatabaseMaintenanceTaskTest extends UnitTestCase {
  public function testRun() {
    $task = new DatabaseMaintenanceTask();
    $task->run();
    // ログが書き込まれているかの確認
  }
}
```

---
# 問題点
* DatabaseMaintenanceTask のユニットテストで確認したいのは「DBの不要データ削除のメンテナンスが正しく実行されるか」ではなく「DBメンテナンスの前後でログがきちんと書き込まれるか」
* DatabaseMaintenanceTask::run() をテスト実行すると、テストの関心ではない DbMaintainer::executeMaintenance() の実行完了を待たねばならず、無駄に時間がかかる。

## 改善の着眼点
テストの際は DbMaintainer::executeMaintenance() を実際に実行させる必要はないので、動作の軽い代用物（モック）と入れ替えられれば良い。

---
# 依存オブジェクトの注入（Dependency Injection）とは
* クラスという具象への依存をなくし、インターフェイスという抽象に依存させることで、依存度を下げる

## サンプルプログラムでは
* DatabaseMaintenanceTask は具体的なクラスである DbMaintainer に依存している。
* 依存先をインターフェイスにして、具体的なクラスは入れ替え可能にする。

---
## インターフェイスとは
* メソッドのリストとそれぞれの定義を約束事として定めるもの。
  * メソッド名
  * 引数（順番、データ型）
  * 戻り値（データ型）
* 実際の処理は持たない。
* 具体的なクラスたちから実装（implements）されることで利用され、定義されたメソッドをちゃんと持っているぞということを保証する。

---
## 説明

```
interface Runnable {
  public function run();
}
```

* 「run()」を定めるインターフェイス Runnable がある。
* ClassAとClassBとがあるとする。
* Runnableインターフェイスを実装している時
  run() を実行できることが保証されている。
* Runnableインターフェイスを実装していない時
  run() を実行できるかどうかは定かではない。

---

```
$a = new ClassA();
$b = new ClassB();
$a->run();
$b->run();
```

### Runnableインターフェイスを実装していればエラーにならない
```
class ClassA implements Runnable{
  public function run() {} //必ず持っている
}
class ClassB implements Runnable{
  public function run() {} //必ず持っている
}
```

### Runnableインターフェイスを実装していなければエラーになるかどうかはやってみないとわからない。
```
class ClassA { /* どんなメソッドを持ってるかわからない */ }
class ClassB { /* どんなメソッドを持ってるかわからない */ }
```

---
# コード修正1
* インターフェイスを追加し、具体的なクラスに実装させる

## メンテナンス実行インターフェイス
```
interface Maintainer {
  public function executeMaintenance(): string;
}
```

---
## インターフェイスを実装する具体的クラス
### データベースメンテナンス実行クラス
```
class DbMaintainer implements Maintainer {
  public function executeMaintenance(): string {
    // とてつもなく重たくて複雑な処理
    return $result_massage;
  }
}
```

### データベースメンテナンス実行クラスのモック
```
class DbMaintainerMock implements Maintainer {
  public function executeMaintenance(): string {
    sleep(3);    // 3秒待つ
    return 'OK';
  }
}
```

---
## ふたつのクラスを入れ替えでも維持されるもの
* DbMaintainerクラス と DbMaintainerMockクラス とは Maintainerインターフェイスの定めた関数とその戻り値を守っているので、Maintainerオブジェクトとしては入れ替え可能。
* どちらのクラスのインスタンスも executeMaintenance() を実行可能で、その戻り値は必ず文字列である。

---
# コード修正2
* インターフェイスに依存させる

<span style="font-size:smaller;">

```
class DatabaseMaintenanceTask {
  private $maintainer; //Maintainerインターフェイスの実装オブジェクト

  // 追加したメソッド
  public function setMaintainer(Maintainer $maintainer) {
    $this->maintainer = $maintainer;
  }

  public function run() {
    //現在時刻をログに書き込む処理

    if (empty($this->maintainer)) {
      $this->maintainer = new DbMaintainer();
    }
    $result = $this->maintainer
                   ->executeMaintenance(); //変更

    //処理結果をログに書き込む処理
    //現在時刻をログに書き込む処理
  }
}
```

</span>

---
### テストコード

```
class DatabaseMaintenanceTaskTest extends UnitTestCase {
  public function testRun() {
    $task = new DatabaseMaintenanceTask();

    // 変更 モックを利用
    $maintainer_mock = new DbMaintainerMock();
    $task->setMaintainer($maintainer_mock);

    $task->run();
    // ログが書き込まれているかの確認
  }
}
```

---
# 改善点
* DatabaseMaintenanceTask::run() をテスト実行しても DbMaintainer::executeMaintenance() は実行されなくなり、テスト完了が早くなった。

↓  
テストしやすくなったことでコードへの変更をしやすくなった。

↓  
より「変更が容易」になったと言える。

---
# DI(Dependency Injection)の仕組みを<br>フレームワークが持ってることがある
* 今回のサンプルではセッターを使ったが、DIを利用するための仕組みをフレームワークが提供していることが多い。
* 設定側と呼び出し側がある。
  * 設定側 : インターフェイス名（呼び出し名）とクラスとを紐付ける
  * 呼び出し側 : インターフェイス名（呼び出し名）を指定してインスタンスを得る

---
# Laravelでの例
## 依存性設定側

<span style="font-size:smaller;">

```
class SampleServiceProvider extends ServiceProvider {
  public function register() {
    $this->app->bind(
      \{ネームスペース}\Maintainer::class,  // インターフェイス指定
      \{ネームスペース}\DbMaintainer::class // 具体的なクラス指定
    );
  }
}
```
</span>

↓  
Maintainerインターフェイスを指定するとDbMaintainerクラスが返ってくるという仕組みが提供されている。

---
## 呼び出し側
* この例ではコントローラー

```
use \{ネームスペース}\Maintainer;

class DatabaseMaintenanceController {
  public function store(Maintainer $maintainer) {
    // この「$maintainer」はDbMaintainer のインスタンス

    $maintainer->executeMaintenance();
    return redirect()->back();
  }
}
```

↓  
インターフェイス「Maintainer」を指定するだけで紐付けられたクラス「DbMaintainer」がロードされる。

---
# 過去の案件でのDI利用
* DBを操作するような管理側の処理は弊社が作る。
* フロント画面は別のデベロッパーが作る。
* 開発は同時にスタートする。
* 弊社が作らないといけない処理を別デベロッパーが必要とするので本来なら弊社の開発が終わらないとフロント画面の開発に入れない。
* 先にインターフェイスの定義だけを進めることで、別デベロッパーはそのインターフェイスを守ったモックをとりあえず利用する。
* 弊社が作る処理が完成したらモックを割り当てていた部分をそれと入れ替えて（変更して）もらう。

↓ 
待ち時間なく開発を進められた。

---
# DIを利用するメリット
* テスト時にモックと入れ替えることができるのでテストしやすい。
* 開発時、具体的な処理の作成されていないクラスをとりあえずモックと入れ替えておいて別の箇所の開発を進められる。
  * 複数のデベロッパーで分業して開発するケース
  * オンラインゲームでサーバープログラムとクライアントプログラムとを同時に開発するケース

具体的な処理内容が変更されてもインターフェイスを守っている限りそれを利用している箇所には影響が及ばない。

↓  
より「変更が容易」になる仕組みだと言える。

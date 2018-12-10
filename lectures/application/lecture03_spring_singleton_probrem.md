# SpringフレームワークのSingleton問題について
* 講義実施者 : 石井 尊
* 講義実施日 : 2018-12-10

---
# 要点
Springフレームワークを扱う際には以下の注意が必要。

* DI（依存性注入）を経由しないとろくにデータベース検索すらできない
* DI経由で取得したオブジェクトはディフォルトでSingletonになってしまう
* Controller や Service といった主要なクラスがSingletonなので、Singletonに満ち溢れた危険な世界になっている
* Singletonにしないようにオブジェクトを作るためには工夫をしなくてはならない

---
# 2018/12/06 に判明したバグ
* Web注文システムの改修案件
* 注文確定時に表示される配達日時が実際にDBに入っている値と異なっていた
* スタッフ総出で調査したが再現方法がわからなかった

---
# 原因は配達日時オブジェクトがSingletonになっていることによるレースコンディション
* 弊社で追加した「配達日時オブジェクト」が原因だった。

## 意図していた動作
* 各ユーザーが操作するごとに配達日時オブジェクトが作られる

## 実際の動作
* Webサイトを使う全ユーザーがひとつの配達日時オブジェクトを使いまわしている

↓  
その結果、他ユーザーによる同タイミングでの操作の影響を受けてしまう「レースコンディション」状態が生まれてしまっていた。

---
# レースコンディションのバグは見つけにくい
* レースコンディションとは「他プロセスからの影響を受けてしまう」ことにより生じるバグで気づきにくい。
  * コンパイルも通る
  * ユニットテストでも検出されない
  * ローカルやステージングでの動作確認でもまず気づかれない
* 逆に言えば今回のようにプログラム上問題なく見えて再現もできず本番環境でも必ず起きているわけではないというバグに遭遇したら「レースコンディションが怪しい」と検討をつけることができるかもしれない。

---
# Spring フレームワークが依存性注入解決で生成するオブジェクトはディフォルトでSingletonである
* Springフレームワークの仕様で、DI（依存性注入）解決で取得されるオブジェクトはディフォルトでSingletonになっている。
* これは「Singleton問題」と言われていて、検索するとこの問題がバグの原因になっているという記事が多く見られる。
* Singletonのオブジェクトに状態を持たせる（＝メンバ変数で保持する値を使う）とレースコンディションの原因となるため、Singletonオブジェクトには状態を持たせてはならない。

---
# Controller も Service も Singleton である
* Webページ表示に必ず使う Controller クラス群がまずSingletonである。
* データベース検索に使われる Service クラス群もSingletonである。
* Singletonのオブジェクトが持つメンバ変数はやはりSingletonとして扱われることになる。
* つまり、他のフレームワークではわざわざ作らないと登場しないSingletonオブジェクトがSpringでは氾濫している。
* むしろオブジェクトをSingletonにしたくない場合に意識的にそれを達成しなくてはならない。

---
# 既存コード
該当案件の既存のプログラム（弊社で手を入れる前の状態）では `@Inject` が多用されている

<span style="font-size:smaller;">

```
@Controller
public class SampleController {
  @Inject
  private OrderService orderService;

  private Long orderId;

  （以下省略）
```

* SampleController 自体がSingletonである
* orderService もSingletonである。
* orderId は依存性注入を経ないただのメンバ変数だが、持ち主である SampleController がSingletonであるため、結局Webサイトに対する全プロセスで共有されてしまう。
</span>


---
# DI解決が必要な理由
<span style="font-size:smaller;">

* そもそも「配達日時オブジェクト」がなぜDI解決を必要とするのか

</span>

## データベースを検索したいだけ
<span style="font-size:smaller;">

* 店舗情報やマスタ情報など、データベースから値を取得したい場合、各テーブルと結びついたDB操作用 Service オブジェクトを利用するようになっている。
* つまり、PHPやRubyでのおなじみのフレームワークのように「モデルクラスのstaticな検索メソッドを呼び出す」という手軽なことができない。
* ServiceクラスのインスタンスはDI経由で取得するようになっている。
* 既存のプログラムではDI経由のオブジェクトは`@Inject`で取得するようになっている。
* `@Inject`を使うためには自分自身が取り出される際にもDI解決経由で取得されねばならない。

</span>

---
# 配達日時オブジェクト：サンプルコード

<span style="font-size:smaller;">

* 配達日時の基準値を受け取って各種計算を施すクラス
* 基準となる配達日時をメンバ変数に保持したい
* 店舗ごとに関連設定が違うので店舗検索の機能もほしい

```
@Component
public class DeliveryPeriod {

  @Inject
  private ShopService shopService; // 店舗ごとの設定検索用

  // 配達日時
  private LocalDateTime deliveryLocalDateTime;

  // ShopServiceを使う
  public void useShopService() {
    this.shopService.doSomething();
  }

  （以下省略）
}
```

※ `@Component` アノテーションをつけることでDIコンテナ経由での取得が可能になる</span>

---
# new で生成するとDI解決されない
* 自作クラスのオブジェクトを使いたいということでシンプルにnewしたくなるが…


## 呼び出し側Controller

```
@Controller
public class SampleController {
  public String index() {

    DeliveryPeriod deliveryPeriod = new DeliveryPeriod();
    deliveryPeriod.useShopService();

    （省略）

    return "sample/index";
  }
```

---
## NG
* DeliveryPeriod をnewで生成してしまうとDI注入がされず、DeliveryPeriod内の ShopService がnullになってしまう。
* DeliveryPeriod はフレームワークによるDI注入の仕組みを経由して、フレームワークに生成させたものを取得しなくてはならない。

---
## DI解決の文脈
* Spring フレームワークでは、現在触っているクラスがDI解決の仕組みの文脈の内側と外側のどちらにいるのかを意識する必要がある。

### DI解決の文脈が必要なクラス
* データベース検索 Service などを利用したい場合
  * 店舗コードを受け取って店舗情報を検索し、該当店舗の営業時間を返す
  * 業態コードを受け取って、該当の業態の店舗数を検索して返す　など

### DI解決の文脈が不要なクラス
* 機能が単純で、他のServiceを利用しなくてもいい場合
  * 文字列を受け取って整形して返すクラス
  * ゲッターとセッターのみ持つデータオブジェクトクラス
  * 数値を受け取って複雑な計算をして返すクラス　など

---
## フレームワークのDI経由で取得する

<span style="font-size:smaller;">

* 既存のコードでは、DI経由で取得するオブジェクトは他の箇所ではすべて`@Inject`または`@Autowired`を使っているのでそれを踏襲する

```
@Controller
public class SampleController {

  @Inject
  private DeliveryPeriod deliveryPeriod; //配達日時オブジェクト

  public String index() {
    this.deliveryPeriod.useShopService();
    （省略）
    return "sample/index";
  }
```

* this.deliveryPeriod はDI解決済み状態で取得される
* DeliveryPeriod内のShopServiceもDI経由で取得され、問題なく使える

</span>

---
## だがNG
* ここでは this.deliveryPeriod もSingletonになっている。
* DI経由で生成したオブジェクトはディフォルトでSingletonになるため



---
# 改善1 : 呼び出される側
<span style="font-size:smaller;">

* Singletonにしないための指定を付ける  
 `@Scope(value = ConfigurableBeanFactory.SCOPE_PROTOTYPE)`

```
@Component
@Scope(value = ConfigurableBeanFactory.SCOPE_PROTOTYPE) //←ここ
public class DeliveryPeriod {
  @Inject
  private ShopService shopService;

  private LocalDateTime deliveryLocalDateTime;

  public void useShopService() {
    this.shopService.doSomething();
  }
  （以下省略）
}
```

* DI経由で生成する DeliveryPeriod オブジェクトが Singleton ではなく、DIコンテナから取り出されるたびに新規オブジェクトになるようになった。

</span>


---
## Controllerで利用してみる
* 取り出し方は以前と同じ`@Inject`経由

```
@Controller
public class SampleController {

  @Inject
  private DeliveryPeriod deliveryPeriod;

  public String index() {
    this.deliveryPeriod.useShopService();
    （省略）
    return "sample/index";
  }
```

---
## 依然NG

<span style="font-size:smaller;">

* deliveryPeriod 内で DI経由オブジェクトは使えるようになってはいる。一見これで良いように見えてしまう。
* しかし、依然としてdeliveryPeriodはSingletonになってしまっている。
* なぜなら、持ち主である Controller 自体が Singleton なので、そもそも this.deliveryPeriod もアプリケーション起動時（サーバーのJava起動時）の一度しか取得されていない。
* `@Inject` が付いているので理解しにくいが、  
  `private DeliveryPeriod deliveryPeriod;`  
  が「このクラスのメンバ変数」であることに変わりはない。
* 持ち主が Singleton オブジェクトであればそのメンバ変数もすべて Singleton として振る舞ってしまう。
* <strong>Controller や Service に持たせるメンバ変数はすべて Singleton</strong> ということになる。

</span>

---
# 改善2 : 呼び出し側
* `@Inject`・`@Autowired`を使うと、DIコンテナからのオブジェクトの取り出しがフレームワークによって暗黙的に行われ、そのタイミングがつかみにくい。
* DI経由でオブジェクトを取得する際、`@Inject`・`@Autowired`以外の別の方法がある


## ApplicationContext.getBean(Bean名)
* Spring フレームワークでは依存性注入の仕組みを経由して管理されるオブジェクトのことを「Bean」と呼ぶ。
* これを使えば、DIコンテナからのオブジェクト取り出しをプログラムで明示的に行うことができる。

---
## 呼び出し側 Controller でgetBean()

<span style="font-size:smaller;">

```
@Controller
public class SampleController {
  @Inject
  private ApplicationContext context; // DIコンテナ機能を持っている

  public String index() {
    DeliveryPeriod deliveryPeriod = 
        this.context.getBean(DeliveryPeriod.class);
    deliveryPeriod.useShopService(); 
    （省略）
    return "sample/index";
  }
```

* OK!
* deliveryPeriod が Controller のメンバ変数ではなくなった。
* `@Scope(value = ConfigurableBeanFactory.SCOPE_PROTOTYPE)`  
  の設定のおかげで、getBean()された際に新しいオブジェクトが生成されるようになっている。

</span>

---
# まとめ

<span style="font-size:smaller;">

* Springでは「DI解決の仕組みが今触っているクラスにまで届いてきているか」を意識しなくてはいけない
* SpringではDI経由で取得されるオブジェクトはディフォルトでSingletonになってしまうので、Singletonだらけの危険な世界になっている
* データベースを扱いつつ、かつSingletonでは困るクラスを作りたい時、そのクラス自体とそれを呼び出す側との両方で工夫が必要になる。
  * コンポーネント（作成したクラス）側では以下を指定する
  `@Scope(value = ConfigurableBeanFactory.SCOPE_PROTOTYPE)`
  * 呼び出し側では`@Inject`を使わず、
  `ApplicationContext.getBean()`を使う

### 補足
* `@Inject`を使ったフィールドでのDI注入は原則として避けるべき。
* [「依存オブジェクトの注入 その2」](../../docs/application/knowledge/low_dependency/dependency_injection2.md)参照

</span>

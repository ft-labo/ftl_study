# 依存オブジェクトの注入<br>（Dependency Injection）
## その2：<br>依存性注入をフィールドで利用するのは避けるべき
* 講義実施者 : 石井 尊
* 講義実施日 : 2018-12-10

---
# 概要
* 依存性の注入をフレームワークに実行させるには複数の選択肢がある。
  * コンストラクタ利用
  * セッター利用
  * フィールド利用
* このうち、フィールドでの利用は避けるべきという知見がある。
  * https://www.vojtechruzicka.com/field-dependency-injection-considered-harmful/
* コンストラクタとセッターとを使い分けると良い

---
## DIコンテナの仕組みを利用するのは共通
* いずれの場合も、DIコンテナの利用を想定しており、依存性解決済みオブジェクトはDIコンテナを通して取得される。
* フレームワークに依存性オブジェクトを自動で注入させる指定を書いておく
  * `@Autowired`
  * `@Inject` など

---
## コンストラクタでの依存性注入とは
* 該当のクラスのコンストラクタに、DI経由で受け取りたいオブジェクトのインターフェイスを指定する。

```
private DependencyA dependencyA;
private DependencyB dependencyB;
private DependencyC dependencyC;

@Autowired
public DI(
  DependencyA dependencyA,
  DependencyB dependencyB,
  DependencyC dependencyC
) {
    this.dependencyA = dependencyA;
    this.dependencyB = dependencyB;
    this.dependencyC = dependencyC;
}
```

---
## セッターでの依存性注入とは
* 該当のクラスに、DI経由で受け取りたいオブジェクトのセッターメソッドを作る。

```
private DependencyA dependencyA;
private DependencyB dependencyB;
private DependencyC dependencyC;

@Autowired
public void setDependencyA(DependencyA dependencyA) {
    this.dependencyA = dependencyA;
}

@Autowired
public void setDependencyB(DependencyB dependencyB) {
    this.dependencyB = dependencyB;
}

@Autowired
public void setDependencyC(DependencyC dependencyC) {
    this.dependencyC = dependencyC;
}
```

---
## フィールドでの依存性注入とは
* 該当クラスのフィールド（メンバ変数）にDI経由での取得を指示する記述を書く。

```
@Autowired
private DependencyA dependencyA;

@Autowired
private DependencyB dependencyB;

@Autowired
private DependencyC dependencyC;
```

---
## フィールドでの依存性注入：長所と短所
### 長所
* 書くコードの量が非常に少なく、エレガントに見える。

---

### 短所
* フレームワークの提供する依存性解決の仕組みを必須にしてしまっている。
  * コンストラクタ利用・セッター利用の場合、フレームワークの依存性解決の仕組みをOFFにしても手動で依存性解決を行うようにコードを整えれば動かすことができる。
  * 単体テストの際はテスト対象の機能以外の余計な要素がないほうが望ましい。
  * フィールド利用の場合、手動で依存性注入を実施する方法がない。そのため、単体テスト時もテスト用にDI解決を行ってくれる特別な仕組みを必要としてしまう。

（続く）

---
### 短所続き
* 該当のオブジェクトを呼び出し側で利用する際、DIコンテナ経由で取得するだけでなく new で取得することができてしまう。
  * new で取得した場合、それ自体はエラーにならないが、該当のオブジェクト内でDI解決がされず、各フィールドのDIオブジェクトが NULL になってしまう。
  * つまりDI経由で取得した場合とnewした場合とで別物になってしまい、オブジェクトとして動作が安定しない。
* DIコンテナの内部でしか利用できないため、DIの仕組みの外側で再利用できない。
  * 単体テストが書きにくい
  * 他のモジュール（＝別に作ったクラス）から利用しにくい

---
## 結論
フィールドでの依存性注入は利用を避けるべき。

### 補足：コンストラクタとセッターの利用が推奨されている
コンストラクタとセッターとで役割分担させるのが良いとされている。
* 必須のものはコンストラクタに
* オプションのものはセッターに

↓  
* ただ Controller などのフレームワークが暗黙的に実行するクラスと、ドメインオブジェクトといった自作クラスとで使い勝手が違うので、利用の状況に合わせて工夫が必要。
* `@Autowired`を使わずにDIコンテナから名前を指定して取得するという手法もある。フレームワークによるが、JavaSpringではDI経由で取得したオブジェクトがディフォルトでSingletonになってしまう問題があるため、この方法を組み合わせる必要がある。

# 開発クオリティ向上のためのノウハウ講義
## 第2回目 各論をまとめて
* 講義実施者 : 石井 尊
* 講義実施日 : 2018-09-28

---
# 今回の講義
* 前回の講義から今日までの間に作成された各論ドキュメントを一通り解説する。
* 文書量（12個）に対して講義時間が限られているので各論の要点を押さえることを重視する。
* もし気になる項目があれば各人が後で該当ドキュメントに目を通すなどして理解を補完してくれれば望ましい。

---
# 各論
ざっくりとテーマごとにグルーピングした。

* 依存関係を管理しよう
* 変更に強いクラスの具体的なコーディングTips
* Tell, don't ask!
* 継承とコンポジション

---
## 依存関係を管理しよう
* [依存関係の管理](/docs/application/knowledge/low_dependency/dependency_management.md)
  * 依存しているとはなにか。
* [依存方向の選択](/docs/application/knowledge/low_dependency/dependency_direction.md)
  * 不安定なものから安定したものへという方向で依存させる。
* [依存オブジェクトの注入（Dependency Injection）](/docs/application/knowledge/low_dependency/dependency_injection.md)
  * 具体的なクラスとモックとを入れ替えられるようにしておく仕組み。
* [インターフェイス（メソッドの仕様）](/docs/application/knowledge/reusability/interface.md)
  * 他のクラスから依存させるための「パブリックな窓口」を整える。
  * 他のクラスが知るべきでないことは隠すべき。

---
## 変更に強いクラスの具体的なコーディングTips
* [引数の順番への依存を取り除く](/docs/application/knowledge/low_dependency/argument_order.md)
  * 引数が多い場合、ハッシュ（連想配列）でやり取りする。
* [依存の隔離](/docs/application/knowledge/easy_to_understand/dependency_isolation.md)
  * 外部クラスを利用する処理はメソッドに切り出しておいて一箇所で管理する。

---
## Tell, don't ask!
* [Tell, don't ask!](/docs/application/knowledge/reusability/tell_dont_ask.md)
  * メッセージ（要求）は端的に最終目的物を求めるべき。
* [無駄な getter と setter を作らない](/docs/application/knowledge/reusability/getter_setter.md)
  * Tell, don't ask! を実践していくと自然と達成される。
  * setter がない＝インスタンス作成後に状態が変化しない＝振る舞いが安定する。
  * 余計な getter がない＝呼び出し側がgetしたものを材料にごちゃごちゃとした処理をしてしまう（Tell, don't ask! の方針に反する）ことを予防する。

---
## 継承とコンポジション
* [継承](/docs/application/knowledge/reusability/inheritance.md)
  * 継承を雑に扱うとコードの品質が落ちる。
  * 継承の適切な使い方を確認する。
* [テンプレートメソッドパターン](/docs/application/knowledge/reusability/template_method_pattern.md)
  * 継承をうまく使って効率化する手法の一例。
* [ダックタイピングとポリモーフィズム（多態性）](/docs/application/knowledge/reusability/duck_typing_polymorphism.md)
  * 共通処理を持たせたいが継承が思い通りに使えないという場合に役立つ手法。
* [コンポジション](/docs/application/knowledge/reusability/composition.md)
  * 「継承よりコンポジション」と言われるほど重視されている手法。
  * 機能を受け継ぎたい相手のインスタンスをプロパティとして持って利用する。

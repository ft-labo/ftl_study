（草稿）

# 依存の隔離
* 依存関係をなくすわけではなく、依存関係を明示するというやり方
* 問題が起こったときの対処を楽にさせる

---
# インスタンス変数の作成の隔離
* 隔離されたことにより、依存していることが公然となる

---
# メソッドへの隔離
* 外部メソッドをラッパーメソッドに隔離する
* 外部メソッドの仕様が変わるたび、その使用箇所で機能が壊される
* DRYの原則であればある処理が2箇所以上で使われたとき行うべきだが、変更の可能性が高いときに隔離することで保険になる
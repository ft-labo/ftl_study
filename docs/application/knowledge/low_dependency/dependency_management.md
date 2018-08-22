# 依存関係の管理

---
# オブジェクトは他のオブジェクトへの依存性を持つ
* オブジェクト指向はオブジェクト同士の相互作用による共同作業。
* メッセージの送り手は受け手のことを「知っている必要」がある。
  * どんなメソッドを持っているか
  * そのメソッドの引数はなにか
* 「知っている」というのは、同時に依存を生む。

---
# サンプルプログラム

<span style="font-size: smaller;">

```
class User {
  // 生年月日（YYYY-MM-DD 型の文字列）を取得
  public function getDateOfBirth(){
    return '1979-1-1'; //モック値
  }
}
```

```
class AgeCalculator {
  /**
   * ユーザーの年齢を計算
   * @param User
   */
  public function getAgeOfUser(User $user){
    $date_string = $user->getDateOfBirth();
    $date_exploded = explode('-', $yyyymmdd); //「-」で分割
    return $this->calculateAge(
      $date_exploded[0],
      $date_exploded[1],
      $date_exploded[2]
    );
  }

  private function calculateAge($year, $month, $day): int{
    //計算処理
  }
}
```

</span>

---
# 依存している状態とは(1)
* 一方のオブジェクトに変更が加えられたとき、他方のオブジェクトも変更する必要があるならば、片方に依存しているオブジェクトがある

↓  
User::getDateOfBirth() の戻り値が変更されたら  
AgeCalculator::calculateAge() の処理も変更しなくてはならない。

↓  
AgeCalculator は User に依存している。

---
# 依存している状態とは(2)
* 以下のものを片方のオブジェクトが知っているとき、オブジェクトの間には依存関係が存在している
  * ほかのクラスの名前  
    例 : AgeCalculatorは、Userという名前のクラスが存在することを予想している
  * self以外のどこかに送ろうとしているメッセージの名前
    例 : AgeCalculatorはUserのインスタンスがメソッドgetDateOfBirth()に応答することを予想している
  * メッセージが要求する引数
  * それらの引数の順番

---
# 依存している状態のデメリット
* 不必要な依存はコードの合理性を損なわせる
* 結合が強固になると、そのうちのひとつだけ再利用というのが難しくなる
  * 再利用が効かないということは、コードの複製を生み、将来的な変更が難しくなる

---
# さまざまな解決・改善方法
各ドキュメント参照

* [依存方向の選択](./dependency_direction.md)
* [引数の順番への依存を取り除く](./argument_order.md)
* [依存の隔離](./dependency_isolation.md)
* [依存オブジェクトの注入（Dependency Injection）](./dependency_injection.md)
* [ラッパーモジュールで複雑な初期化を隔離](./wrapper_module.md)

---
# 依存関係の解消や改善は常に冗長化になる
* コスパを見極めること。
* ルールにとらわれるあまりに割に合わない作り込みをしないこと。

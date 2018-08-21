# 依存方向の選択

---
# ケーススタディ
* ユーザーを登録し、現在の年齢を取得したい。
* ユーザーには生年月日を登録させ、現在の日時と照らして年齢を計算する。

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
# AgeCalculator → [依存] → User
* AgeCalculator は User に依存している。
* なぜなら、AgeCalculator は User::getDateOfBirth() の戻り値が「ハイフンつながりの 年-月-日 という文字列」であることを知っているから。
* なので、受け取った文字列が年月日の数値になるように分割してから計算している。

---
# 変更シミュレーション
* 生年月日は「YYYY-MM-DD」形式の一つの文字列ではなく、「年」「月」「日」と3つの数値で持つことになった。
* それに伴い、User::getDateOfBirth() メソッドの戻り値が文字列から連想配列に変更された。

```
class User {
  （プロパティ省略）

  /**
   * 生年月日を取得
   * @return array 連想配列
   */
  public function getDateOfBirth(){
    return [
      'year'  => $this->year,
      'month' => $this->month,
      'day'   => $this->day
    ];
  }
}
```

---
# AgeCalculatorの修正
AgeCalculator::getAgeOfUser() は User::getDateOfBirth() の戻り値が「ハイフンつながりの 年-月-日 という文字列」であることを前提にしていたので、Userの変更に従って変更を余儀なくされる。

```
class AgeCalculator {
  /**
   * ユーザーの年齢を計算
   * @param User
   * @return int
   */
  public function getAgeOfUser(User $user){
    $params = $user->getDateOfBirth();
    return $this->getAge(
      $params['year'],
      $params['month'],
      $params['day']
    );
  }
  （以後省略）
}
```
---
# Userの変更にAgeCalculatorが引っ張られるのが鬱陶しい
* Userのデータ管理方法は今後も変更がちょくちょくありそう。
* その都度AgeCalculatorまで修正するのはコストがかかる。
* AgeCalculatorがUserの影響を受けないように改善したい。

↓  
依存方向を整えようという発想が役立つ。

---
# 依存方向の選択
* 依存関係は逆転可能
* どこに依存させるかの基準「自分より変更されないものに依存しなさい」
  * 多くのところから依存されたクラスを変更すると、広範囲に影響が及ぶ
  * 具象クラスは抽象クラスより変わる可能性が高い

* あるクラスが他のクラスより要件が変わりやすいとき
  * 要件が変わりやすいクラスに対する依存はなるべく作らない

---
# ケーススタディ
* User と AgeCalculator の依存関係を逆転させる
* User : 変更が多い
* AgeCalculator : 変更少ない
* 依存するなら User が AgeCalculator に依存すべき

---
# サンプルプログラム修正
<span style="color:gray; font-size:smaller;">※そもそも AgeCalculator は不要なのではないかというのはこの例では考慮しない</span>

```
class User {
  /**
   * 年齢を取得
   */
  public function getAge() {
    return AgeCalculator::getAge(
      $this->year,
      $this->month,
      $this->day
    );
  }
}
```

```
class AgeCalculator {
  public static function getAge($year, $month, $day) {
    //計算処理
  }
}
```

---
# 改善点
* User のデータ構造や処理が変更されても AgeCalculator を修正する必要がない。
* より変更されない方のクラスであるAgeCalculatorに依存されている。

↓  
より「変更が容易になった」といえる。

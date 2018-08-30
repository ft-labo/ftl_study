# 無駄な getter と setter を作らない

---
# getter と setter を機械的に作るという習慣にメスを入れる
* 「クラスに private/protected なプロパティを作成したら自動的にそれぞれ getter と setter を作ることが習慣になっており特に疑問に感じたことがない」というケースがある。
* 実はそうやって機械的に作る getter と setter はその多くが不必要で、プログラムに余計な邪魔者になっていると考えることができる。
* 「無駄な getter と setter を作らない」という視点を導入し、実践することでプログラムの品質を高めることができる。

※ Rubyには「attr_accessor」という気が利いた仕組みがあり、実装者が getter や setter を作ることがないので今回の話の対象ではないかもしれない。

---
# ここで言う getter とは
* private/protected なプロパティの値を無判断・無加工で返却する public なメソッド。
* getXXX() という名前のメソッドすべてということではない。

---
# ケーススタディ
* 日本史の教材プログラム
* 戦国時代にフォーカス
* 戦国大名の情報を画面に表示する

---
# 戦国大名クラス

<span style="font-size:smaller;">

```
class SengokuDaimyo {
  private $family_name; //姓
  private $given_name; //名
  private $year_birth; //生年
  private $year_death; //没年
  private $gender; //性別

  public function __construct(
    $family_name, $given_name, $year_birth, $year_death, $gender ){
    /*省略*/
  }

  public function getFamilyName(){ /*省略*/ }
  public function getGivenName(){ /*省略*/ }
  public function getYearBirth(){ /*省略*/ }
  public function getYearDeath(){ /*省略*/ }
  public function getGender(){ /*省略*/ }

  public function setFamilyName($family_name){
    $this->amily_name = $family_name; //タイプミスしている
  }
  public function setGivenName($given_name){ /*省略*/ }
  public function setYearBirth($year_birth){ /*省略*/ }
  public function setYearDeath($year_death){ /*省略*/ }
  public function setGender($gender){ /*省略*/ }
}
```

</span>

---
## 呼び出し側
### Controller

```
$kambei = 
  new SengokuDaimyo('黒田', '官兵衛', 1546, 1604, 'male');

$this->set('kambei', $kambei);
```

### View

<span style="font-size:smaller;">

```
名前 : <?php echo($kambei->getFamilyName()); ?>　
       <?php echo($kambei->getGivenName()); ?><br>
死亡時年齢 : 
  <?php echo(
    $kambei->getYearDeath() - $kambei->getYearBirth()
  ); ?> 歳<br>
性別 : 
  <?php if ($kambei->getGender() == 'male') { ?>
    男性
  <?php } else { ?>
    女性
  <?php } ?>
```

</span>


---
# この時点での振り返り
* [Tell, don't ask.](./tell_dont_ask.md) の原則に反している。（別ドキュメント参照）
* 機械的に作った setter を使っている箇所がない  
  →それら setter は不要なので削除可能ということ
* setFamilyName() メソッドの処理にタイプミスがあるが、現段階ではどこからも呼び出されていないのでエラーが表面化しない。
  * 開発が進むことでいつかこのメソッドが呼び出されてエラーを引き起こす可能性がある。
  * バグがあるクラスなのにバグがないかのようにみなされて開発が進んでしまう。


---
# getter の罠
* getter で何でも返してしまうと、「受け取った側がそれを材料にしてなにか操作をする」ということを促してしまう。
* Tell, don't ask. でいう ask を招きやすい。
* Tell されたもの（要求されている最終成果物）だけ返却するほうが望ましい。

---

# SengokuDaimyo クラスにおける setter は何を意味するか
* 「姓が変わる」「名が変わる」「生没年が変わる」など、（ほぼ）ありえないことをしようとしている。

```
$mituhide =
  new SengokuDaimyo('明智', '光秀', 1528, 1582, 'male');

$mituhide->setGender('female'); //女性になった
```

---
# setter が無いことで安定度が増す

* インスタンス化されてから変更されることがおかしいプロパティの場合、setterを持たないほうが自然で合理的である。
* インスタンス生成後にプロパティが変更されないオブジェクトのほうが変更されるオブジェクトよりも振る舞いが安定してバグが少なくなる。
* プロパティの変更が必要でないのであれば振る舞いの安定のために setter を持たないという制限が課されている方が良い。

## 不安定なオブジェクトの例
* インスタンス「obj」が生成されて直後の「obj->doSomething()」ではエラーになっていないが、様々な処理を経た後の30行後の「obj->doSomething()」がエラーの原因になっている、というようなケース

---
# 使わないメソッドは無いに越したことはない
* メソッドが存在する限り、それが使われてエラーの原因になる潜在的な可能性がある。
* メソッドが存在しなければ、エラーの可能性になる可能性はゼロである。
* 機械的にメソッドをはやしていると、プロパティの数が多いクラスでは膨大な量の getter setter がクラスに存在することになってしまい、単純に可読性が落ちる。

---
# コードの改善

<span style="font-size:smaller;">

```
class SengokuDaimyo {
  （プロパティ・コンストラクタ省略）

  public function getFullName(){
    return $this->family_name.'　'.$this->given_name;
  }

  public function getAgeAtDeath(){
    if (is_numeric($this->year_birth) &&
        is_numeric($this->year_death)) {
      return ($this->year_death - $this->year_birth).'歳';
    } else {
      return '生年/没年未詳';
    }
  }

  public function getGenderExpression(){
    if ($this->gender == 'male') {
      return '男性';
    } else
    if ($this->gender == 'female') {
      return '女性';
    } else {
      return '性別未詳';
    }
  }
}
```

</span>

---

### View

<span style="font-size:smaller;">

```
名前 : <?php echo($mitunari->getFullName()); ?><br>
死亡時年齢 : <?php echo($mitunari->getAgeAtDeath()); ?><br>
性別 : <?php echo($mitunari->getGenderExpression()); ?>
```

</span>

---
# 改善点
* Tell, don't ask. に従った。呼び出しView側がスッキリし再利用性が高まった。
* 使ってないメソッドがなくなったことでエラーの潜在的な原因となるメソッドの総数を減らすことができた。
* setter がなくなることでインスタンス生成の段階でオブジェクトの状態が確定し不変となり、振る舞いの安定度が向上したと考えられる。

↓  
「不要な getter setter は作らない」という方針によって、より「変更が容易」なプログラムになったと言える。

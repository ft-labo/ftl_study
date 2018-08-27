# Tell, don't ask!

---
# Tell, don't ask!<br>（要求を伝えろ、問い合わせるな）とは
* オブジェクト指向プログラムにおいて望ましいとされるふるまいの法則。
* オブジェクトに対しては要求のみを端的に伝えるべきで、条件分岐のための問い合わせをいちいちするなという考え方。
* 条件分岐が必要なら呼び出し側ではなく呼び出されるクラス側でさばくべきだということ。
* 呼び出し側からの端的な要求に応えられるようにクラスを設計する。

---
# ケーススタディ
* RPGのブラウザゲームのWebサイト
* 画面上に様々なゲーム情報を表示する

---
## サンプルプログラム

<span style="font-size:smaller;">

### 各ジョブのクラス
```
// 戦士
class Warrior {}

// 忍者
class Ninja {}

// 魔法使い
class Wizard {}
```

### コントローラー
```
// 冒険者酒場に登録されているメンバー
$all_adventurers = [
  new Warrior(), new Warrior(),
  new Ninja(),   new Ninja(),
  new Wizard(),  new Wizard()
];

// 編成されたパーティーのメンバー
$adventurers = [ new Warrior(), new Ninja(), new Wizard() ];
```

</span>

---
### 酒場名簿
* 酒場に登録されている冒険者の簡易的な情報をテーブルで一覧表示
* プレイヤーは酒場に登録されている冒険者から数人選んでパーティーを組む。

<span style="font-size:smaller;">

```
<?php foreach ($all_adventurers as $adventurer) { ?>
  （前略）

  <!-- 戦闘距離 -->
  <td>
    <?php if($adventurer instanceof Warrior) { ?>
      近
    <?php } else if($adventurer instanceof Ninja) { ?>
      中
    <?php } else if($adventurer instanceof Wizard) { ?>
      遠
    <?php } ?>
  </td>

  （後略）
<?php } ?>
```

</span>

---
### パーティーメニュー画面でのメンバー一覧画面
* 酒場より少し詳しい冒険者情報を一覧表示

<span style="font-size:smaller;">

```
（前略）

<!-- 戦闘距離 -->
<td>
  <?php if($adventurer instanceof Warrior) { ?>
    近
  <?php } else if($adventurer instanceof Ninja) { ?>
    中
  <?php } else if($adventurer instanceof Wizard) { ?>
    遠
  <?php } ?>
</td>

<!-- 武器 -->
<td>
  <?php if($adventurer instanceof Warrior) { ?>
    剣
  <?php } else if($adventurer instanceof Ninja) { ?>
    手裏剣
  <?php } else if($adventurer instanceof Wizard) { ?>
    ファイアーボール
  <?php } ?>
</td>

（後略）
```

</span>

---
### メンバー詳細画面
* 詳しい冒険者情報を表示

<span style="font-size:smaller;">

```
（前略）

<!-- タフネス -->
<td>
  <?php if($adventurer instanceof Warrior) { ?>
    高
  <?php } else if($adventurer instanceof Ninja) { ?>
    中
  <?php } else if($adventurer instanceof Wizard) { ?>
    低
  <?php } ?>
</td>

<!-- フレーバーテキスト -->
<td>
  <?php if($adventurer instanceof Warrior) { ?>
    村を滅ぼされ、復習を誓う
  <?php } else if($adventurer instanceof Ninja) { ?>
    主君からの命令で派遣された
  <?php } else if($adventurer instanceof Wizard) { ?>
    魔法研究のために冒険している
  <?php } ?>
</td>

（後略）
```

</span>

---
# Ask しているとは
* 冒険者インスタンスに対して「あなたは戦士？それとも忍者？それとも魔法使い？」とジョブをいちいち問い合わせてif文で条件分岐している。

# 問題点
* 異なるページで同じ出力をしたいだけの場合でもいちいち条件分岐から書いている。
* コードの繰り返しが多い。
* ジョブの種類が増えると増えた分だけ各if文の条件分岐が増えることになる。
* 各ジョブについての情報がいろいろなところに分散していてそのジョブの全容がわかりにくい。

---
# Tell, don't ask! に従って改善
* 各表示ページを修正し、Ask している箇所を Tell するように修正。
* 各ジョブクラスを改善し、要求に端的に応じるメソッドを追加。
* 各ジョブごとに応答内容を記述。

---
# 冒険者インターフェイス
* 冒険者のジョブを表すクラスであればこのメソッドを持ってるよというルールを定義する。

```
interface Adventurer {
  // 戦闘距離
  public function getBattleRange(): string;

  // 武器
  public function getWeapon(): string;

  // タフネス
  public function getToughness(): string;

  // フレーバーテキスト
  public function getFlavorText(): string;
}
```

---
## 各ジョブのクラス - 戦士

```
class Warrior implements Adventurer {
  public function getBattleRange(): string {
    return '近';
  }

  public function getWeapon(): string {
    return '剣';
  }

  public function getToughness(): string {
    return '高';
  }

  public function getFlavorText(): string {
    return '村を滅ぼされ、復習を誓う';
  }
}
```

---
## 各ジョブのクラス - 忍者

```
class Ninja implements Adventurer {
  public function getBattleRange(): string {
    return '中';
  }

  public function getWeapon(): string {
    return '手裏剣';
  }

  public function getToughness(): string {
    return '中';
  }

  public function getFlavorText(): string {
    return '主君からの命令で派遣された';
  }
}
```

---
## 各ジョブのクラス - 魔法使い

```
class Wizard implements Adventurer {
  public function getBattleRange(): string {
    return '遠';
  }

  public function getWeapon(): string {
    return 'ファイアーボール';
  }

  public function getToughness(): string {
    return '低';
  }

  public function getFlavorText(): string {
    return '魔法研究のために冒険している';
  }
}
```

---
# 表示ページ
* 各コードの前後には省略部分があり、ここでは割愛している。

<span style="font-size:smaller;">

### 酒場名簿
```
<!-- 戦闘距離 -->
<td><?php $adventurer->getBattleRange(); ?></td>
```

### パーティーメンバー一覧
```
<!-- 戦闘距離 -->
<td><?php $adventurer->getBattleRange(); ?></td>

<!-- 武器 -->
<td><?php $adventurer->getWeapon(); ?></td>
```

### 冒険者詳細
```
<!-- タフネス -->
<td><?php $adventurer->getToughness(); ?></td>

<!-- フレーバーテキスト -->
<td><?php $adventurer->getFlavorText(); ?></td>
```
</span>

---
# Tell するとは
オブジェクトに対して「具体的にはどういう処理をするのかは知らないがこれをしろ」とゴールを示すこと。

* 「戦闘距離をくれ」 : getBattleRange()
* 「武器をくれ」 : getWeapon()
* 「タフネスをくれ」 : getToughness()
* 「フレーバーテキストをくれ」 : getFlavorText()

---
# 改善点
* 呼び出し側でいちいち問い合わせ→条件分岐をしなくなったことでコードがシンプルになり読みやすくなった。
* メソッド名が端的に何を返すのかを知らせているのでわかりやすくなった。
* ジョブの種類が増えても呼び出し箇所での修正は不要。
* 各ジョブのクラスごとにそれぞれ自分についての情報を集約的に持つのでどこに何が書かれているのかがわかりやすくなった。
* コードの繰り返しが減り、再利用性が高まった。

↓  
**Tell, don't ask!** の方針に従うことで、より「変更が容易」なプログラムになったと言える。

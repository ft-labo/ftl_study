# テンプレートメソッドパターン

---
# 概要
* 似たようなことをしているクラスがたくさんある場合、テンプレートメソッドパターンを使って改善できることがある。

---
# ケーススタディ
* フレームワークを用いたWebシステム。
* このフレームワークでは送信されるメールのパターンごとにMailクラスを作るようになっている。
  * ユーザー登録完了のお知らせ
  * お問い合わせ受領のお知らせ
  * サーバーメンテナンスに伴うサービス一時停止のお知らせなど

---
# サンプルコード
* `Mail`はフレームワークの用意しているメール用クラス
* `build()`はフレームワークにより実装を強制されるメソッド。  
  メールの必要情報を作成し、送信する。

<span style="font-size:smaller; color:gray;">
※ 以下のコードは実際に案件で遭遇したケースをモデルにしている。
</span>


---

### ユーザー登録完了メール

<span style="font-size:smaller;">

```
class UserRegistrationMail extends Mail {
  public function __construct($user) { /*省略*/}

  public function build() {
    // 件名
    $subject = 'ユーザー登録完了';

    //送信元
    $mail_from = 'info@example.com';

    // 本文テンプレート
    $lang = $this->user->lang();
    $template
      = 'emails.'.$lang.'.user.registration';

    //メール送信
    return $this
           ->subject($subject)
           ->from($mail_from)
           ->text($template)
           ->with ([ 'name' => $this->user->getName() ]);
  }
}
```

</span>

---

### ユーザー名変更完了メール

<span style="font-size:smaller;">

```
class UserChangeNameMail extends Mail {
  public function __construct($user, $old_user_name) { /*省略*/ }

  public function build() {
    // 件名
    $subject = 'ユーザー名変更完了';

    //送信元
    $mail_from = 'info@example.com';

    // 本文テンプレート
    $lang = $this->user->lang();
    $template
      = 'emails.'.$lang.'.user.change_name';

    //メール送信
    return $this
           ->subject($subject)
           ->from($mail_from)
           ->text($template)
           ->with ([
             'name' => $this->user->getName(),
             'old_name' => $this->old_user_name,
           ]);
  }
}
```

</span>

---
# 変更シミュレーション1
* さらに「ユーザーが退会した際に送信されるメール」のためのMailクラスを追加することになった。

---

### ユーザー削除完了メール

<span style="font-size:smaller;">

```
class UserDeleteMail extends Mail {
  public function __construct($user) { /*省略*/ }

  public function build() {
    // 件名
    $subject = '退会しました';

    //送信元
    $mail_from = 'info@example.com';

    // 本文テンプレート
    $lang = $this->user->lang();
    $template
      = 'emails.'.$lang.'.user.delete';

    //メール送信
    return $this
           ->subject($subject)
           ->from($mail_from)
           ->text($template)
           ->with ([ 'name' => $this->user->getName() ]);
  }
}
```

</span>

---
# 変更シミュレーション2
* メール送信者が`info@example.com`から`noreply@example.com`に変更になった。

---

### ユーザー登録完了メール

```
    $mail_from = 'noreply@example.com';
```

### ユーザー名変更完了メール

```
    $mail_from = 'noreply@example.com';
```

### ユーザー削除完了メール

```
    $mail_from = 'noreply@example.com';
```


---
# 問題
* 各Mailクラス はコピペで複製された処理が多い。
* コードは共通してるのに再利用性が低いということ。
* 同一の内容の変更のためにすべてのクラスで同一の修正をしなくてはならないようになっている。

# 改善欲求
* 処理の再利用を用いて効率よくできないか。

↓  
こういうケースにぴったりなのが **テンプレートメソッドパターン** 。

---
# テンプレートメソッドパターンとは
* デザインパターンのひとつ。
* デザインパターンとは「オブジェクト設計において定石となる手法をパターン化したもの」。
* 継承を利用し、スーパークラスに共通する処理を定義し、サブクラスには個々の固有の部分だけを実装させる。
* サブクラスが詳細を実装するための抽象メソッドをスーパークラスに定義しておくという手法が使われる。
* 共通メソッド内で抽象メソッドを呼ぶことで処理内の差異の部分がサブクラスごとに入れ替わる。
* 細部が違うだけで似たような処理を持つクラスが多数存在する場合に便利。

---
# コンパクトな解説コード

```
abstract class GreetingPrinter {
  public function print() {
    echo $this->greeting().', '.$this->target().'.<br>';
  }

  // サブクラスに実装を強制する抽象メソッド
  abstract protected function greeting();
  abstract protected function target();
}
```

```
class HelloWorld extends GreetingPrinter {
  protected function greeting() { return 'Hello'; }
  protected function target() { return 'world'; }
}
```

```
class GoodbyeEveryone extends GreetingPrinter {
  protected function greeting() { return 'Goodbye'; }
  protected function target() { return 'everyone'; }
}
```

---
## 呼び出し


```
$hello_world = new HelloWorld();
$hello_world->print();
$goodbye_everyone = new GoodbyeEveryone();
$goodbye_everyone->print();
```

## 結果


```
Hello, world.
Goodbye, everyone.
```

---
# Mailのサンプルコードを改善

### テンプレートメソッドパターンを利用した抽象クラス
<span style="font-size:smaller;">

```
class BaseMail extends Mail {
  protected $user;
  protected $mail_from = 'noreply@example.com';

  public function __construct($user) { /*省略*/ }

  // 共通処理（テンプレートメソッド）
  public function build() {
    $lang = $this->user->lang();
    $template
      = 'emails.'.$lang.'.'.$this->getTemplatePath();

    return $this
           ->subject($this->getSubject())
           ->from($this->mail_from)
           ->text($template)
           ->with($this->getVariables());
  }

  // サブクラスに実装を促す抽象メソッド
  abstract protected function getSubject();
  abstract protected function getTemplatePath();
  abstract protected function getVariables();
}
```
</span>

---

### ユーザー登録完了メール

<span style="font-size:smaller;">

```
class UserRegistrationMail extends BaseMail {
  protected function getSubject() {
    return 'ユーザー登録完了';
  }

  protected function getTemplatePath() {
    return 'user.registration';
  }

  protected function getVariables() {
    return [ 'name' => $this->user->getName() ];
  }
}
```

</span>

---

### ユーザー名変更完了メール

<span style="font-size:smaller;">

```
class UserChangeNameMail extends BaseMail {
  public function __construct($user, $old_user_name) {
    $this->user = $user;
    $this->old_user_name = $old_user_name;
  }

  protected function getSubject() {
    return 'ユーザー名変更完了';
  }

  protected function getTemplatePath() {
    return 'user.change_name';
  }

  protected function getVariables() {
    return [
     'name' => $this->user->getName(),
     'old_name' => $this->old_user_name,
    ];
  }
}
```

</span>

---

### ユーザー削除完了メール

<span style="font-size:smaller;">

```
class UserDeleteMail extends BaseMail {
  protected function getSubject() {
    return '退会しました';
  }

  protected function getTemplatePath() {
    return 'user.delete';
  }

  protected function getVariables() {
    return ['name' => $this->user->getName()];
  }
}
```

</span>


---
# 改善
* テンプレートメソッドパターンを利用したことで、詳細な処理を記述する箇所が BaseMail の一箇所になった。
* フレームワークのMailクラスの挙動や、サイト全体で共通で利用しているメール送信元の指定などに変更が生じても、修正が一箇所で済むようになった。
* 各具象クラスに記述される内容がそのクラスに特有の要素だけになり、わかりやすくなった。
* Mailのバリエーションの追加も容易にできる。

↓  
より「変更が容易」になったと言える。

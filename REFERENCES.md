# REFERENCES — My Rails Way の下敷き

[RAILS_WAY.md](RAILS_WAY.md) の各規約が依って立つ記事・資料。⭐ は特に影響の大きいもの。

## 思想の主柱

- ⭐ **The Rails Doctrine** — DHH
  [原文](https://rubyonrails.org/doctrine) / [公式日本語訳](https://rubyonrails.org/doctrine/ja)
  「設定より規約」「メニューはおまかせ」など Rails の設計思想 9 原則の原典。「Rails Way とは何か」の定義そのもの。
- ⭐ **Vanilla Rails is plenty** — Jorge Manrubia（37signals）
  [原文](https://dev.37signals.com/vanilla-rails-is-plenty/) / [日本語訳（TechRacho）](https://techracho.bpsinc.jp/hachi8833/2023_01_12/124378)
  「素の Rails はスケールしない」への正面反論。Service 層を挟まずコントローラからドメインモデルの public API を呼ぶ設計を Basecamp の実績で裏付ける。§0「Vanilla Rails に乗る」の主柱。
- **The Majestic Monolith** — DHH
  [原文](https://signalvnoise.com/svn3/the-majestic-monolith/)
  小規模チームは統合されたモノリスを意図的に選ぶべきという主張。サービス切り出しへの誘惑に対する基準線。

## モデリング / ドメイン

- ⭐ **Rails: Arkencyが考える「2026年のRails Way」** — Andrzej Krzywda（Arkency）
  [日本語訳（TechRacho）](https://techracho.bpsinc.jp/hachi8833/2026_05_22/157922)
  「enum 遷移 → コールバック → Service → ジョブ」という実務 Rails の事実上の標準パターンに名前を与えて可視化する記事。§3「エンティティ/プロセスのステート区別」「コールバックチェーンに埋めない」の下敷き。
- **私の好きなコード（1）大胆かつ的確なドメイン駆動開発** — Jorge Manrubia
  [原文](https://dev.37signals.com/domain-driven-boldness/) / [日本語訳（TechRacho）](https://techracho.bpsinc.jp/hachi8833/2023_03_02/126285)
  ドメイン語彙を大胆にコードへ焼き込む命名・モデリング論。vanilla Rails と DDD は両立するという実証。
- **私の好きなコード（3）"正しく書かれた" concerns** — Jorge Manrubia
  [原文](https://dev.37signals.com/good-concerns/) / [日本語訳（TechRacho）](https://techracho.bpsinc.jp/hachi8833/2023_04_04/127023)
  concern を「雑多コードの押し込み先」でなく「has trait / acts as を表す凝集単位」として使う設計原則。PORO への委譲例つき。
- **私の好きなコード（5）永続化とロジックを絶妙にブレンドするActive Record** — Jorge Manrubia
  [原文](https://dev.37signals.com/active-record-nice-and-blended/) / [日本語訳（TechRacho）](https://techracho.bpsinc.jp/hachi8833/2023_04_18/127103)
  「永続化とロジックは分離すべき」通説への反論。Repository 層を入れない理由の言語化。
- **英語の非可算名詞を ActiveSupport::Inflector で適切に扱う** — Andy Croll
  [日本語訳（TechRacho）](https://techracho.bpsinc.jp/hachi8833/2026_06_19/157585)
  `inflect.uncountable` の正しい使い方。命名がテーブル名・routing helper・autoload に波及する話。§3 inflection 規約の下敷き。

## ルーティング / コントローラ

- ⭐ **Railsのルーティングを極める（後編）** — baba（BPS）
  [記事（TechRacho）](https://techracho.bpsinc.jp/baba/2020_11_20/15619)
  `resources` / `resource` / `member` / `collection` の使い分けと「RESTful にしようと頑張り過ぎない」バランス。§1 の下敷き。
- **DHHはどのようにRailsのコントローラを書くのか** — Jerome Dalbert
  [原文](http://jeromedalbert.com/how-dhh-organizes-his-rails-controllers/) / [日本語訳（POSTD）](https://postd.cc/how-dhh-organizes-his-rails-controllers/)
  「カスタムアクションを足すくらいなら新しいリソースを切る」DHH 流 CRUD 純化。§1「動詞をリソースに昇格」の出典。

## Service Object 批判

- **Service Objectがアンチパターンである理由とよりよい代替手段** — Jared White
  [原文](https://intersect.whitefusion.io/the-art-of-code/why-service-objects-are-an-anti-pattern) / [日本語訳（TechRacho）](https://techracho.bpsinc.jp/hachi8833/2022_01_20/55130)
  Service Object には可読性も関心の分離も本質的な力はないと断じ、concern + ドメインモデリングされた PORO への置き換えを示す。

## 卒業論 — Rails Way をいつ・どう離れるか

- ⭐ **Railsアプリが「Rails-way」を卒業するとき（4）複雑なRailsアプリを支える5つの土台** — Paweł Dąbrowski（Arkency）
  [日本語訳（TechRacho）](https://techracho.bpsinc.jp/hachi8833/2026_06_10/158257)
  10万行超の複雑さを支える DDD・ミューテーションテスト・イベントソーシング・CQRS・AI の5層。どれも「複雑な領域への部分適用」が正解という主張。§8 の下敷き。
- **Rails Way, or the highway** — Vladimir Dementyev（Evil Martians, Kaigi on Rails 2024）
  [Speaker Deck](https://speakerdeck.com/palkan/kaigi-on-rails-2024-rails-way-or-the-highway)
  「Rails Way は規約でなくアプリ構築の哲学」。成長したアプリで MVC を壊さずレイヤーを増やす側の視点。
- **It deserved its own tome: Layered Design and the Extended Rails Way** — Vladimir Dementyev / Travis Turner（Evil Martians）
  [原文](https://evilmartians.com/chronicles/it-deserved-its-own-tome-layered-design-and-the-extended-rails-way)
  書籍『Layered Design for Ruby on Rails Applications』の著者インタビュー。「Extended Rails Way」の概観。

## 日本語コミュニティの一次資料

- ⭐ **Simplicity on Rails — RDB, REST and Ruby** — 諸橋恭介（moro）、Kaigi on Rails 2023
  [Speaker Deck](https://speakerdeck.com/moro/simplicity-on-rails-rdb-rest-and-ruby)
  イベントのリソース化・`has_many :through`・入力と業務ロジックの分離で「複雑な要求をシンプルな Rails に落とす」方法論。resources ベース設計の日本語最良資料の一つ。
- **Ruby on Railsの正体と向き合い方** — 後藤優一（yasaichi）、Rails Developers Meetup 2019
  [Speaker Deck](https://speakerdeck.com/yasaichi/what-is-ruby-on-rails-and-how-to-deal-with-it)
  Rails がリソース〜テーブルを密結合させて「速くてキレイ」を実現した設計意図の解剖。Rails Way が「なぜ・どこまで」効くのかの構造的理解。

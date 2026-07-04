# My Rails Way

個人開発の Rails アプリに共通して適用する設計思想とハウススタイル。整形・スタイルなど RuboCop で機械検査できるものは [`rubocop/`](rubocop/) が正本で、本書は **lint で強制できない設計判断だけ**を断定形で書く。

> これはあくまで個人開発における自分の流儀であって、汎用のベストプラクティス集ではない。チームで開発するならチームの規約を優先する。

## 0. 原則

- **Vanilla Rails に乗る。** フレームワークと喧嘩しない。Rails ネイティブの道具（ActiveRecord・partial・helper・concern・Turbo / Stimulus）で書き切れなくなった証拠が出るまで、新しい抽象層（Service Object 基盤・ViewComponent・form object gem 等）を導入しない。抽象の導入は「便利そう」ではなく「現状の道具で破綻した実例」で正当化する。
- **規約は構造で強制する。** 守らせたい規約は可能な限り RuboCop cop・DB 制約・strict locals・CI で機械強制し、人の規律（「レビューで気をつける」）に依存させない。散文規約に残すのは lint で表現できない設計判断だけ。
- **複雑さには部分適用で応える。** DDD・イベントソーシング・CQRS のような重い道具は「全面導入 vs 未導入」の二択にしない。素の Rails で始め、複雑さが実証された領域にだけ段階的に足す（→ [REFERENCES](REFERENCES.md): Arkency「複雑な Rails アプリを支える5つの土台」）。
- **スタイルは omakase。** 整形の議論に時間を使わない。`rubocop-rails-omakase` をベースに、上乗せは [`rubocop/base.yml`](rubocop/base.yml) の明示的な差分だけ。

## 1. ルーティング — `resources` / `resource` 基調

- ルートは `resources` / `resource` で宣言する。`get "/foo" => "bar#baz"` のようなアドホックルートを足さない。カスタムアクションが欲しくなったら、まず「それは別リソースの CRUD ではないか」を疑う（`orders/:id/cancel` ではなく `resources :cancellations` のように、動詞をリソースに昇格できないか）。
- 使わないアクションは `only:` / `except:` で必ず塞ぐ。読み取り専用リソースは `only: [ :index, :show ]`。破壊的操作はコントローラで弾く前に**ルーティング段階で存在させない**。
- それでも残るカスタムアクションは `member`（`:id` あり・特定リソース対象）/ `collection`（`:id` なし・全体対象）で追加する。「複数形（collection）には id がなく、単数形（member）には id がある」。
- singleton リソース（ユーザーから見て1つしかないもの: プロフィール・設定等）は `resource`（単数）。その場合もコントローラ名は複数形になることを前提に命名する。
- 例外（webhook 受け口・health check・OAuth コールバック等、外部仕様が URL を決めるもの）は認める。ただし**例外である理由をルート定義にコメントで明記**する。
- `via:` なしの `match` は書かない。旧式の `":controller/:action"` ワイルドカードルーティングは書かない。

## 2. コントローラ

- **strong parameters は `params.expect`。** `params.require(:m).permit(...)` を書かない。改ざんされた構造（hash でない値の送りつけ）で `require().permit()` は 500（`NoMethodError`）になるが、`expect` は `ParameterMissing` → 400 に倒れる。単一フィールドの取り出しも `params.dig` / `params[]` でなく `expect`。フォーム経由の通常ミス（present な空文字）は 422、構造的に壊れた入力だけ 400、という責務分離。
- **`params` を読むのは action と抽出境界（`*_params`）だけ。** private なロジックメソッドは `params` を読まず、必要な値を引数で受け取る。`params` への暗黙依存を作らない。
- **`before_action :set_x` で ivar を代入しない。** 値を返す finder を action で明示呼び出しする（`@user = find_user!(params[:token])`）。失敗分岐は `rescue_from` に集約する。action を読めばそのページに何が要るか分かる状態を保つ。
- **単発のビュー用データはコントローラが ivar で渡す。** `helper_method` は `current_user` のような横断アクセサ専用にし、「ページデータの取得口」として露出しない。
- **`Current` はリクエスト層に閉じる。** コントローラ / ビューは `current_user` 等の helper_method 越しにアクセスし、`Current.user` を直書きしない。ドメイン層・サービスは `Current` を読まず、必要な値を引数で受け取る（隠れたグローバル依存を作らない）。

## 3. モデル / ドメイン

- **エンティティのステートとプロセスのステートを区別して設計する。** モデルのカラムには「物の属性」（名前・金額）と「処理がいまどのステップか」（`status` enum・`last_reminder_sent_at`・`failed_attempts`）が混在しがちである。後者が増殖してきたら、それは独立したプロセス（別モデル・別テーブル）が埋まっているサイン（→ REFERENCES: Arkency「2026年の Rails Way」）。
- **ビジネスプロセスをコールバックチェーンに埋めない。** 「enum 遷移 → `after_update` → Service 起動 → ジョブ enqueue」の暗黙連鎖でプロセスを表現しない。プロセスには持ち主（それを一望できる明示的なメソッド / オブジェクト）を与える。コールバックの用途は同一モデル内の派生データ整合（正規化・denormalized カラム更新）までに絞る。
- **不変条件を伴う書き込みは guarded class-method writer に集約する。** 正規化・検証・採番のような不変条件つきの書き込みは、caller 側で組み立てて `create!` / `upsert` を直叩きせず、モデルの `Model.verb!`（例: `Dictionary.learn!`）に一本化する。全 caller・単発 / 一括の双方で検証が必ず走り、ドリフトを構造で防ぐ。一括 `upsert` 系は validation を通らないため、writer 側の検証に加えモデル `validate` でも強制する（多重防御）。
- **フィルタは scope に encapsulate する。** `where(active: true)` を caller に散らさず `scope :active` にする。フィルタ済み部分集合を関連名そのもの（`items`）で返さない（全件と誤認させる）。
- enum は `prefix: true` + `validate: true` を付ける（`Order.paid?` の名前空間衝突と不正値の黙殺を防ぐ）。
- インスタンス変数 / メソッド名はモデル名に揃える（`@email_ingress` / `email_ingress`）。型が分かる名前にする。
- **inflection は設計初期に整える。** staff / metadata のような非可算のドメイン語は `config/initializers/inflections.rb` の `inflect.uncountable` で宣言する（テーブル名・routing helper・関連名・autoload の全部に波及するため後から直すのは高くつく）。ただし登録するのは実際に使うドメイン語だけ。気に入らないテーブル名の回避に使わない。頭字語は `acronym`、不規則複数形は `irregular` を使い分ける（→ REFERENCES: Andy Croll）。
- **カレンダー日とシステム時刻を型で区別する。** 事実としての「日付」（取引日・締め日）は `Date`、イベントの発生時刻（`created_at` / `seen_at`）は `Time`。元データに時刻精度がないものを `Time` にしない（TZ 混入と捏造精度の温床）。
- クラス / モジュール内部だけで使う定数は `private_constant` で隠蔽する。公開 API の定数だけを public に残す。

## 4. View

- **ビューで DB クエリを発行しない。** `.exists?` / `.count` / `where` を `.erb` に書かない。クエリはコントローラで実行し、ivar かプリロード済みデータを渡す。全ページで描画されるレイアウト内の集計クエリは特に禁止。
- **View は Rails ネイティブで組む**（partial + strict locals + presenter + helper + CSS component 層）。ViewComponent 等の View 抽象 gem は入れない。CRUD 主体・再利用 widget 少数の個人開発規模では抽象コストが便益を上回る。重複は種類で解き分ける: **スタイルの重複は CSS、構造の重複は partial、表示ロジックの散在は presenter**。
- **再利用 partial は strict locals 必須。** 複数箇所から呼ぶ `.erb` は先頭で `<%# locals: (...) %>` を宣言し、暗黙の変数スコープ依存を禁止する。引数契約の取り違えが `StrictLocalsError` で構造検出される。
- **表示ロジックは presenter / 対象別 helper へ。** モデル 1 件に紐づく表示ロジック（ラベル・色 class・フォールバック名）は presenter PORO（`app/presenters`）に凝集し、ActiveRecord / ActionView 非依存に保って単体テストする。presenter は Rails が提供する層ではなく、ただの PORO を `app/presenters/` に置くだけの自作規約（`app/` 直下のディレクトリは Zeitwerk が autoload する）。Draper のような decorator gem は入れない。汎用フォーマッタは対象別 helper へ。`ApplicationHelper` は横断 glue だけに保ち、ゴミ箱にしない。
- **反復するユーティリティクラスの塊は CSS 側で束ねる**（Tailwind なら `@utility` で `card` のような component クラスに）。純スタイルの重複を Ruby の wrapper partial で包まない。

## 5. JavaScript

- **増分 DOM は server が駆動する。** 一覧追記・部分置換は client で DOM を組み立てず Turbo Stream（server がレンダリングした断片）で差し込む。Stimulus controller は糊（接続・イベント・lazy 初期化）に徹し、HTML を生成しない。
- **third-party JS は self-host する。** CDN を参照せず importmap + `vendor/javascript` に同梱する（CSP の `script-src` を self だけで済ませる）。重い library は `connect` で動的 `import()`。
- **意味論を client / server で二重定義しない。** バリデーション・整形・分類規則は server を単一ソースにし、client にコピーしない。

## 6. 配置

- **Service 層を設けない。** ビジネスプロセスは、それが属する集約の名前空間配下のドメインオブジェクト（`app/models/<aggregate>/` の PORO）に本物の名前で書く（`Household::Purge`・`User::Deletion`）。`XxxService` という命名は禁止 — 「Service」は "何かをするもの" という同語反復で、責務を名指ししない。エントリポイントも `.call` でなく動詞メソッド（`purge!` / `confirm` / `intake`）にする（→ REFERENCES: Vanilla Rails is plenty）。
- **実体のないトップレベル名前空間を作らない。** 集約ルートは ActiveRecord モデル。対応するエンティティを持たない「概念」（`Review::` のような）をディレクトリ都合で名前空間に昇格しない。
- **読み取り専用の集計・検索は `app/queries`。** 副作用を持たない query object の家。
- **外部 API クライアント・I/O adapter は `lib/`。** ドメインロジック・状態遷移・バリデーションを持ち込まない「通信の代理人」に徹する。役割語（Client / Adapter）はこの層でのみ使う。
- request 状態に依存しない純粋ロジックはコントローラ concern でなく `lib/` の純モジュールに置く。コントローラ concern は「コントローラ層の振る舞い」専用。
- 決定論的なドメインロジックが育ったら `lib/<domain>` の **ActiveRecord 非依存な純 PORO** に隔離し、Rails との授受は value object だけで行う（写像は Rails 側が所有）。単体で速くテストでき、フレームワークの都合から切り離される。
- 一回限りの運用スクリプトは eager-load される `app/` 配下に置かず、非 autoload の one-shot 置き場に隔離する（常設コードと区別する）。

## 7. テスト

- **既存の regression テストを削除・改変して緑を作らない。** 仕様を変えたときだけテストを変え、その理由をコミットに残す。
- **外部 I/O（API・メール・決済）はモックし、テストはネットワークに出ない。**
- lint / 型チェックの緑をランタイム検証の代替にしない。実挙動で裏取りする。
- テストの長さ・expectation 数は取り締まらない（omakase と同じ判断。価値のある correctness 系 cop だけ有効化する → `rubocop/rspec.yml`）。

## 8. 卒業の条件 — Rails Way をいつ離れるか

- 素の Rails で始める。本書の規約は全て「素の Rails のまま秩序を保つ」ためのもの。
- コードベースが大きく複雑になった領域には、DDD（まずビジネス理解と命名）→ 複雑ワークフローへのイベントソーシング → 複数表示形式が要る領域への CQRS、を**その領域に限定して**足す。全面移行はしない（→ REFERENCES: Arkency「5つの土台」）。
- 新しい抽象を入れるときは「再評価の発火条件」を先に書く（例: ViewComponent は「状態持ち widget が 10 個を超え、かつ component 単体テストを契約にしたくなったら、全面移行として再検討」）。条件なしの「とりあえず導入」をしない。

# rails-way

個人開発の Rails アプリに共通して適用している設計思想（My Rails Way）と、共有 RuboCop 設定。

> **はじめに（免責）**: ここに書いてあるのは、あくまで**自分が個人開発でやっているやり方**です。汎用のベストプラクティス集ではありませんし、正解を主張するものでもありません。チームで開発するなら、チームのやり方・規約をもちろん優先してください。

## 構成

| ファイル | 役割 |
| --- | --- |
| [`RAILS_WAY.md`](RAILS_WAY.md) | 設計思想とハウススタイルの本体。RuboCop で機械検査**できない**設計判断だけを断定形で書く |
| [`rubocop/base.yml`](rubocop/base.yml) | 共有 RuboCop 設定（`rubocop-rails-omakase` ベース + 明示的な上乗せ）。機械検査**できる**規約の正本 |
| [`rubocop/rspec.yml`](rubocop/rspec.yml) | RSpec を使うアプリ向けの追加層（opt-in） |
| [`REFERENCES.md`](REFERENCES.md) | 参考文献。この Way の下敷きになっている記事・資料 |

散文（RAILS_WAY.md）と lint（rubocop/）で正本を分けているのは、「機械で強制できる規約は機械に強制させ、散文には設計判断だけを残す」ため。同じルールを二重に書かない。

## RuboCop 設定の使い方

gem として git 参照し、`inherit_gem` で継承する（[rubocop-rails-omakase](https://github.com/rails/rubocop-rails-omakase) と同じ方式）。

```ruby
# Gemfile
group :development do
  gem "rubocop-rails-omakase", require: false
  gem "rails_way", github: "kotonococ0425/rails-way", require: false
end
```

```yaml
# .rubocop.yml（Minitest のアプリ）
inherit_gem:
  rails_way: rubocop/base.yml
```

```yaml
# .rubocop.yml（RSpec のアプリ。rubocop-rspec / rubocop-rspec_rails も Gemfile に必要）
inherit_gem:
  rails_way:
    - rubocop/base.yml
    - rubocop/rspec.yml
```

アプリ固有の cop・上書きは、各アプリの `.rubocop.yml` にこの継承の**下**へ書き足す。

### ローカルで編集しながら試す

参照元アプリで bundler の local git override を使う:

```bash
bundle config set --local local.rails_way /path/to/rails-way  # clone した場所
```

（解除は `bundle config unset --local local.rails_way`。lockfile の revision とブランチが一致している必要がある）

## License

[MIT](LICENSE)。ドキュメント・設定とも自由にどうぞ。ただし上記の通り、これは一人の開発者の流儀のスナップショットです。

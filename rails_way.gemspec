# frozen_string_literal: true

# rails-way を inherit_gem で参照可能にするための最小 gemspec。
# rubygems.org への公開は想定しない（Gemfile から git 参照する）。
Gem::Specification.new do |spec|
  spec.name    = "rails_way"
  spec.version = "0.1.0"
  spec.authors = [ "kotonococ0425" ]
  spec.license = "MIT"

  spec.summary     = "My Rails Way — 個人開発 Rails の設計思想と共有 RuboCop 設定"
  spec.description = "個人開発の Rails アプリに共通適用する設計思想ドキュメント（RAILS_WAY.md）と、" \
                     "rubocop-rails-omakase ベースの共有 RuboCop 設定（rubocop/base.yml, rubocop/rspec.yml）。"
  spec.homepage    = "https://github.com/kotonococ0425/rails-way"

  spec.files = Dir["rubocop/**/*.yml", "*.md", "LICENSE"]

  spec.metadata["rubygems_mfa_required"] = "true"
end

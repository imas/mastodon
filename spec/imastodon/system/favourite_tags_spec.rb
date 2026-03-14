# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'お気に入りタグ', :js, type: :system do
  include ProfileStories
  include ImastodonSystemHelpers

  context 'お気に入りタグが1件登録されているシングルカラムUIの場合' do
    it 'Compose Panelにお気に入りタグ一覧が表示される'

    it 'タグ名をクリックするとそのタグTLに遷移する'

    it 'ロックボタンをクリックすると投稿テキストにタグが挿入される'

    it '折りたたみボタンで開閉できる'
  end

  context '設定画面でのCRUD操作' do
    it 'お気に入りタグを追加できる'

    it 'お気に入りタグを削除できる'
  end

  context 'ハッシュタグタイムライン上部の場合' do
    it 'お気に入りタグ追加ボタンが表示される'
  end
end

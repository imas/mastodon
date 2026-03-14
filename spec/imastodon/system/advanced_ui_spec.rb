# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'マルチカラムUI', :js, type: :system do
  include ProfileStories
  include ImastodonSystemHelpers

  context 'マルチカラムUIを有効にした場合' do
    context 'お気に入りタグ' do
      it 'Composeカラムにお気に入りタグ一覧が表示される'

      it '折りたたみボタンで開閉できる'
    end

    context 'アバターオーバーレイアイコン' do
      it 'unlisted投稿のアバターに公開範囲アイコンが表示される'
    end

    context 'ja-IMロケール' do
      it '投稿ボタンのテキストが「あふぅ」である'
    end
  end
end

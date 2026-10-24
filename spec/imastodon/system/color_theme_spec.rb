# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'imastodon カラーテーマ', :js, type: :system do
  include ProfileStories
  include ImastodonSystemHelpers

  context 'シンデレラをダークで使う場合' do
    it 'カラムの外側の背景がテーマと同じ色相になる'
    it 'セレクトボックスの背景が不透明で、選択肢の一覧が透けない'
    it '二次テキストが背景に透けない'
  end

  context 'シンデレラをライトで使う場合' do
    it 'カラムの外側の背景がテーマと同じ色相になる'
    it 'セレクトボックスの背景が不透明で、選択肢の一覧が透けない'
  end

  context 'ハイコントラストを有効にした場合' do
    it 'ボタンの色がテーマの色相のまま変わらない'
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'アイマストドンのロゴ', :js, type: :system do
  include ProfileStories
  include ImastodonSystemHelpers

  context '新ナビの左上' do
    it 'サイト名の代わりにアイマストドンのワードマークが出る'
  end

  context '設定画面のサイドバー' do
    it 'デスクトップ幅ではワードマークが潰れずに出る'
    it 'スマホ幅では上部にアイマストドンのワードマークが出る'
  end
end

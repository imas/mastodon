# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'カスタムブランディング', type: :system do
  context '存在しないパスにアクセスした場合' do
    it 'エラーページにちひろさんの画像が表示される' do
      visit '/nonexistent-path-xyz-404'
      expect(page).to have_css('img[src="/chihiro_san.png"]')
    end
  end
end

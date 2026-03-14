# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ja-IMロケール', :js, type: :system do
  include ProfileStories
  include ImastodonSystemHelpers

  context 'ロケールをja-IMに設定した場合' do
    it '投稿ボタンのテキストが「あふぅ」である'

    it 'ブーストボタンが「わかるわ」と表示される'
  end
end

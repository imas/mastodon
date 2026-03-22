# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ja-IMロケール', :js, type: :system do
  include ProfileStories
  include ImastodonSystemHelpers

  context 'ロケールをja-IMに設定した場合' do
    before do
      login_and_visit_spa
      ignore_js_error(/MISSING_TRANSLATION/)
      change_user_locale('ja-IM')
      visit '/'
      wait_for_react
    end

    after do
      change_user_locale('ja')
    end

    it '投稿ボタンのテキストが「あふぅ」である' do
      submit_button = find('.compose-form button[type="submit"]')
      expect(submit_button).to have_text('あふぅ')
    end

    it 'ブーストボタンが「わかるわか引用」と表示される' do
      status = Fabricate(:status, account: bob.account, text: 'わかるわテスト投稿', visibility: :public)
      FeedManager.instance.push_to_home(bob.account, status)
      visit '/home'
      wait_for_react
      expect(page).to have_button('わかるわか引用')
    end
  end
end

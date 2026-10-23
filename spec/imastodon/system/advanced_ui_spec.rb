# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'マルチカラムUI', :js, type: :system do
  include ProfileStories
  include ImastodonSystemHelpers

  context 'マルチカラムUIを有効にした場合' do
    before do
      login_and_visit_spa
      enable_advanced_ui
      visit '/deck'
      wait_for_react
    end

    after do
      disable_advanced_ui
    end

    context 'アバターオーバーレイアイコン' do
      it 'unlisted投稿のアバターに公開範囲アイコンが表示される' do
        status = Fabricate(:status, account: bob.account, text: 'デッキテスト投稿（未収載）', visibility: :unlisted)
        FeedManager.instance.push_to_home(bob.account, status)
        visit '/deck/timelines/home'
        wait_for_react
        article = find('article[data-id]', text: 'デッキテスト投稿（未収載）')
        expect(article).to have_css('header .account__avatar-overlay-icon-overlay')
      end
    end

    context 'ja-IMロケール' do
      before do
        ignore_js_error(/MISSING_TRANSLATION/)
        change_user_locale('ja-IM')
        visit '/deck'
        wait_for_react
      end

      after do
        change_user_locale('ja')
      end

      it '投稿ボタンのテキストが「あふぅ」である' do
        within('nav') { click_on '新しいあふぅ' }
        within('form[role="dialog"]') do
          expect(page).to have_button('あふぅ', type: 'submit')
        end
      end
    end
  end
end

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

    context 'お気に入りタグ' do
      before do
        FavouriteTag.create!(account: bob.account, name: 'imasdecktest', visibility: :public)
        visit '/deck'
        wait_for_react
      end

      it 'Composeカラムにお気に入りタグ一覧が表示される' do
        expect(page).to have_css('.compose__extra')
        expect(page).to have_css('.compose__extra__body__name', text: '#imasdecktest')
      end

      it '折りたたみボタンで開閉できる' do
        foldable = find('.compose__extra .scrollable.optionally-scrollable')
        within('.compose__extra__header__fold__icon') { click_button }
        expect(foldable['style']).to include('height: 0px')
        within('.compose__extra__header__fold__icon') { click_button }
        expect(foldable['style']).to_not include('height: 0px')
      end
    end

    context 'アバターオーバーレイアイコン' do
      it 'unlisted投稿のアバターに公開範囲アイコンが表示される' do
        status = Fabricate(:status, account: bob.account, text: 'デッキテスト投稿（未収載）', visibility: :unlisted)
        FeedManager.instance.push_to_home(bob.account, status)
        visit '/deck/timelines/home'
        wait_for_react
        status_wrapper = first('.status__wrapper-unlisted')
        expect(status_wrapper).to have_css('.account__avatar-overlay-icon-overlay')
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
        submit_button = find('.compose-form button[type="submit"]')
        expect(submit_button).to have_text('あふぅ')
      end
    end
  end
end

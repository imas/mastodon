# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'お気に入りタグ', :js, type: :system do
  include ProfileStories
  include ImastodonSystemHelpers

  context 'お気に入りタグが1件登録されているシングルカラムUIの場合' do
    before do
      login_and_visit_spa
      FavouriteTag.create!(account: bob.account, name: 'imastest', visibility: :public)
      visit '/'
      wait_for_react
    end

    it 'Compose Panelにお気に入りタグ一覧が表示される' do
      expect(page).to have_css('.compose__extra')
      expect(page).to have_css('.compose__extra__body__name', text: '#imastest')
    end

    it 'タグ名をクリックするとそのタグTLに遷移する' do
      find('.compose__extra__body__name', text: '#imastest').click
      expect(page).to have_current_path(%r{/timelines/tag/imastest|/tags/imastest})
    end

    it 'ロックボタンをクリックすると投稿テキストにタグが挿入される' do
      within('.compose__extra li', text: '#imastest') do
        click_button class: 'favourite-tags__lock'
      end
      expect(find('.autosuggest-textarea__textarea').value).to include('#imastest')
    end

    it '折りたたみボタンで開閉できる' do
      expect(page).to have_css('.compose__extra .foldable--visible')
      within('.compose__extra__header__fold__icon') { click_button }
      expect(page).to have_no_css('.compose__extra .foldable--visible')
      within('.compose__extra__header__fold__icon') { click_button }
      expect(page).to have_css('.compose__extra .foldable--visible')
    end
  end

  context '設定画面でのCRUD操作' do
    before { login_and_visit_spa }

    it 'お気に入りタグを追加できる' do
      visit '/settings/favourite_tags'
      fill_in 'favourite_tag_name', with: 'imassettings'
      click_button type: 'submit'
      expect(page).to have_css('td', text: 'imassettings')
    end

    it 'お気に入りタグを削除できる' do
      FavouriteTag.create!(account: bob.account, name: 'imasdelete', visibility: :public)
      visit '/settings/favourite_tags'
      expect(page).to have_css('td', text: 'imasdelete')
      within('tr', text: 'imasdelete') do
        find('a[data-method="delete"]').click
      end
      expect(page).to have_no_css('td', text: 'imasdelete')
    end
  end

  context 'ハッシュタグTLの「…」メニューの場合' do
    def open_hashtag_menu
      # 項目を押した直後はメニューが閉じる途中なので、閉じきってから開く
      expect(page).to have_no_css('[role="menuitem"]')
      find('header:has(h1) button[aria-haspopup="menu"]').click
    end

    def click_menu_item(message_id)
      find('[role="menuitem"]', text: frontend_translations(message_id)).click
    end

    before do
      Fabricate(:tag, name: 'imastodon')
      login_and_visit_spa('/tags/imastodon')
    end

    it 'お気に入りタグ（公開）に追加できる' do
      open_hashtag_menu
      click_menu_item('tag.add_favourite.public')

      # 追加の API 呼び出しが終わって一覧が読み直されると、メニューの文言が切り替わる
      open_hashtag_menu
      expect(page).to have_css('[role="menuitem"]', text: frontend_translations('tag.remove_favourite.public'))
      expect(FavouriteTag.where(account: bob.account, name: 'imastodon', visibility: :public)).to exist
    end

    it '登録済みのお気に入りタグ（公開）を外せる'
    it 'お気に入りタグ（未収載）に追加できる'
  end
end

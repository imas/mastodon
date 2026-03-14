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
      expect(find('.autosuggest-textarea__textarea').value).to match(/#imastest/)
    end

    it '折りたたみボタンで開閉できる' do
      foldable = find('.compose__extra .scrollable.optionally-scrollable')
      within('.compose__extra__header__fold__icon') { click_button }
      expect(foldable['style']).to include('height: 0px')
      within('.compose__extra__header__fold__icon') { click_button }
      expect(foldable['style']).to_not include('height: 0px')
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

  context 'ハッシュタグタイムライン上部の場合' do
    before do
      login_and_visit_spa
      page.execute_script(<<~JS)
        window.history.pushState({}, '', '/timelines/tag/imastodon');
        window.dispatchEvent(new PopStateEvent('popstate', { state: {} }));
      JS
      have_css('.column-header')
    end

    it 'お気に入りタグ追加ボタンが表示される' do
      first('button.column-header__button').click
      expect(page).to have_css('.favourite-tags__add-button-in-column')
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'お気に入りタグ', :js, type: :system do
  include ProfileStories
  include ImastodonSystemHelpers

  context '投稿小窓の場合' do
    def open_composer
      within('nav') { click_on frontend_translations('tabs_bar.publish') }
      expect(page).to have_css('form[role="dialog"]')
    end

    def favourite_tags_button
      find('form[role="dialog"] button', text: frontend_translations('compose_form.favourite_tags'))
    end

    before do
      login_and_visit_spa
      FavouriteTag.create!(account: bob.account, name: 'imastest', visibility: :public)
      FavouriteTag.create!(account: bob.account, name: 'imasunlisted', visibility: :unlisted)
      open_composer
    end

    it 'お気に入りタグボタンからお気に入りタグの一覧を開ける' do
      favourite_tags_button.click
      expect(page).to have_css('[role="menuitemcheckbox"]', text: '#imastest')
    end

    def toggle_lock(tag_name)
      favourite_tags_button.click
      find('[role="menuitemcheckbox"]', text: "##{tag_name}").click
      send_keys :escape
      expect(page).to have_no_css('[role="menuitemcheckbox"]')
    end

    def close_composer
      # ヘッダーの右端が閉じるボタン。ラベルは aria-labelledby の参照先にあり、Capybara では名前で探せない
      find('form[role="dialog"] header button:last-of-type').click
    end

    def compose_text
      find('form[role="dialog"] textarea').value
    end

    it 'タグをロックすると本文にタグが入り、ボタンにロック中の件数が出る' do
      toggle_lock('imastest')

      expect(compose_text).to include('#imastest')
      expect(favourite_tags_button).to have_text("#{frontend_translations('compose_form.favourite_tags')}(1)")
    end

    it 'ロックを外すと本文からタグが消え、件数も消える' do
      toggle_lock('imastest')
      expect(compose_text).to include('#imastest')

      toggle_lock('imastest')
      expect(compose_text).to_not include('#imastest')
      expect(favourite_tags_button).to have_no_text('(')
    end

    it '小窓を閉じて開き直しても、ロック表示と本文の差し込みが一致する' do
      toggle_lock('imastest')

      close_composer
      expect(page).to have_no_css('form[role="dialog"]')
      open_composer

      expect(compose_text).to include('#imastest')
      favourite_tags_button.click
      expect(page).to have_css('[role="menuitemcheckbox"][aria-checked="true"]', text: '#imastest')
    end

    it '本文がロック中のタグだけなら、小窓を閉じても破棄の確認が出ない' do
      toggle_lock('imastest')

      close_composer
      expect(page).to have_no_css('form[role="dialog"]')
      expect(page).to have_no_text(frontend_translations('compose.cancel_modal.title'))
    end

    it '未収載のタグをロックすると公開範囲が未収載になる' do
      toggle_lock('imasunlisted')

      within('form[role="dialog"]') do
        expect(page).to have_button(frontend_translations('compose.privacy.unlisted'))
      end
    end

    it 'メニューからお気に入りタグの設定画面を開ける'

    context 'お気に入りタグが1件も無い場合' do
      it '登録されていない旨が出る'
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

    it '登録済みのお気に入りタグ（公開）を外せる' do
      FavouriteTag.create!(account: bob.account, name: 'imastodon', visibility: :public)
      visit '/tags/imastodon'
      wait_for_react

      open_hashtag_menu
      click_menu_item('tag.remove_favourite.public')

      open_hashtag_menu
      expect(page).to have_css('[role="menuitem"]', text: frontend_translations('tag.add_favourite.public'))
      expect(FavouriteTag.where(account: bob.account, name: 'imastodon')).to_not exist
    end

    it 'お気に入りタグ（未収載）に追加できる' do
      open_hashtag_menu
      click_menu_item('tag.add_favourite.unlisted')

      open_hashtag_menu
      expect(page).to have_css('[role="menuitem"]', text: frontend_translations('tag.remove_favourite.unlisted'))
      expect(page).to have_css('[role="menuitem"]', text: frontend_translations('tag.add_favourite.public'))
      expect(FavouriteTag.where(account: bob.account, name: 'imastodon').pluck(:visibility)).to eq ['unlisted']
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AvatarOverlayIcon', :js, type: :system do
  include ProfileStories
  include ImastodonSystemHelpers

  context 'unlisted投稿がホームTLに表示される場合' do
    it 'アバターに公開範囲アイコンが表示される' do
      login_and_visit_spa
      status = Fabricate(:status, account: bob.account, text: 'テスト投稿（未収載）', visibility: :unlisted)
      FeedManager.instance.push_to_home(bob.account, status)
      visit '/home'
      wait_for_react
      status_wrapper = first('.status__wrapper-unlisted')
      expect(status_wrapper).to have_css('.account__avatar-overlay-icon-overlay')
    end

    it '公開範囲アイコンがアバター画像の右下角に配置される' do
      login_and_visit_spa
      status = Fabricate(:status, account: bob.account, text: 'テスト投稿（未収載）', visibility: :unlisted)
      FeedManager.instance.push_to_home(bob.account, status)
      visit '/home'
      wait_for_react
      expect(page).to have_css('.status__wrapper-unlisted .account__avatar-overlay-icon-overlay')
      rects = page.evaluate_script(<<~JS)
        (() => {
          const container = document.querySelector('.status__wrapper-unlisted .account__avatar-overlay');
          const base = container.querySelector('.account__avatar-overlay-icon-base');
          const overlay = container.querySelector('.account__avatar-overlay-icon-overlay');
          const b = base.getBoundingClientRect();
          const o = overlay.getBoundingClientRect();
          return { baseRight: b.right, baseBottom: b.bottom, overlayRight: o.right, overlayBottom: o.bottom };
        })()
      JS
      expect(rects['overlayRight']).to be_within(1).of(rects['baseRight'])
      expect(rects['overlayBottom']).to be_within(1).of(rects['baseBottom'])
    end
  end

  context 'public投稿がホームTLに表示される場合' do
    it 'アバターに公開範囲アイコンが表示されない' do
      login_and_visit_spa
      status = Fabricate(:status, account: bob.account, text: 'テスト投稿（公開）', visibility: :public)
      FeedManager.instance.push_to_home(bob.account, status)
      visit '/home'
      wait_for_react
      status_wrapper = first('.status__wrapper-public')
      expect(status_wrapper).to have_no_css('.account__avatar-overlay-icon-overlay')
    end
  end
end

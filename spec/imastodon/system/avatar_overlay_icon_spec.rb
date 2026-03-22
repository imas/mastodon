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

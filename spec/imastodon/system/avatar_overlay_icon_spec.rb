# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AvatarOverlayIcon', :js, type: :system do
  include ProfileStories
  include ImastodonSystemHelpers

  def visit_home_with(text, visibility)
    login_and_visit_spa
    status = Fabricate(:status, account: bob.account, text: text, visibility: visibility)
    FeedManager.instance.push_to_home(bob.account, status)
    visit '/home'
    wait_for_react
    find('article[data-id]', text: text)
  end

  context 'unlisted投稿がホームTLに表示される場合' do
    it 'アバターに公開範囲アイコンが表示される' do
      article = visit_home_with('テスト投稿（未収載）', :unlisted)
      expect(article).to have_css('header .account__avatar-overlay-icon-overlay')
    end

    it '公開範囲アイコンの背景が不透明で、アバターの上でも見える' do
      article = visit_home_with('テスト投稿（未収載）', :unlisted)
      icon = article.find('header .account__avatar-overlay-icon-overlay')

      # 色の書式（rgb() や color()）に左右されないよう、canvas に塗ってアルファ値を読む
      alpha = page.evaluate_script(<<~JS, icon)
        ((el) => {
          const ctx = document.createElement('canvas').getContext('2d');
          ctx.fillStyle = getComputedStyle(el).backgroundColor;
          ctx.fillRect(0, 0, 1, 1);
          return ctx.getImageData(0, 0, 1, 1).data[3];
        })(arguments[0])
      JS
      expect(alpha).to eq 255
    end
  end

  context 'public投稿がホームTLに表示される場合' do
    it 'アバターに公開範囲アイコンが表示されない' do
      article = visit_home_with('テスト投稿（公開）', :public)
      expect(article).to have_css('header .account__avatar')
      expect(article).to have_no_css('header .account__avatar-overlay-icon-overlay')
    end
  end
end

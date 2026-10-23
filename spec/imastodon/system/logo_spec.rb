# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'アイマストドンのロゴ', :js, type: :system do
  include ProfileStories
  include ImastodonSystemHelpers

  # 画像は読み込みが終わるまで幅が 0 なので、描画されるまで待ってから測る
  def rendered_width(element)
    element.synchronize do
      width = element.evaluate_script('this.getBoundingClientRect().width')
      raise Capybara::ExpectationNotMet, 'まだ描画されていない' if width.zero?

      width
    end
  end

  context '新ナビの左上' do
    it 'サイト名の代わりにアイマストドンのワードマークが出る' do
      login_and_visit_spa

      within('#skip-link-target-nav') do
        wordmark = find('img[src*="logo_full_imastodon"]')
        expect(rendered_width(wordmark)).to be >= 100
      end
    end
  end

  context '設定画面のサイドバー' do
    # スマホ幅のテストで変えた大きさが後続のテストに残らないよう、Playwright の既定に戻す
    after { page.current_window.resize_to(1280, 720) }

    it 'デスクトップ幅ではワードマークが潰れずに出る' do
      login_and_visit_spa
      visit '/settings/preferences'

      wordmark = find('.sidebar > a img[src*="logo_full_imastodon"]')
      expect(rendered_width(wordmark)).to be >= 180
    end

    it 'スマホ幅では上部にアイマストドンのワードマークが出る' do
      login_and_visit_spa
      page.current_window.resize_to(390, 844)
      visit '/settings/preferences'

      wordmark = find('.sidebar__toggle__logo img[src*="logo_full_imastodon"]')
      expect(rendered_width(wordmark)).to be >= 100
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ナビゲーション', :js, type: :system do
  include ProfileStories
  include ImastodonSystemHelpers

  context 'ログインユーザーがシングルカラムUIを使っている場合' do
    before { login_and_visit_spa }

    it 'ナビゲーションパネルにFAQリンクがある' do
      nav_panel = find('.navigation-panel')
      expect(nav_panel).to have_link(href: 'https://faq.imastodon.net/getting-started/')
    end

    it 'ログイン後のデフォルトページがローカルTLである' do
      expect(page).to have_current_path(%r{/public/local})
    end
  end
end

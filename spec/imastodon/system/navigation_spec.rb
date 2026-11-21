# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ナビゲーション', :js, type: :system do
  include ProfileStories
  include ImastodonSystemHelpers

  context 'ログインユーザーがシングルカラムUIを使っている場合' do
    before { login_and_visit_spa }

    it 'ログイン後のデフォルトページがローカルTLである' do
      expect(page).to have_current_path(%r{/public/local})
    end
  end

  context 'ログインユーザーがマルチカラムUIを使っている場合' do
    before do
      login_and_visit_spa
      enable_advanced_ui
    end

    after do
      disable_advanced_ui
    end

    it '/home を開くとローカルTLへ飛ばされずにホームTLが表示される' do
      visit '/home'
      wait_for_react

      # マルチカラムでは upstream が /deck 配下のホームへ寄せる
      expect(page).to have_current_path('/deck/home')
    end
  end
end

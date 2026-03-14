# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ナビゲーション', :js, type: :system do
  include ProfileStories
  include ImastodonSystemHelpers

  context 'ログインユーザーがシングルカラムUIを使っている場合' do
    it 'ナビゲーションパネルにFAQリンクがある'

    it 'ログイン後のデフォルトページがローカルTLである'
  end
end

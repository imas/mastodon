# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '投稿小窓の投票', :js, type: :system do
  include ProfileStories
  include ImastodonSystemHelpers

  context '投稿小窓を開いた場合' do
    it '投票ボタンが表示されない'
  end
end

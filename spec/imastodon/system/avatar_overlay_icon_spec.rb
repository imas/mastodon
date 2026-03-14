# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AvatarOverlayIcon', :js, type: :system do
  include ProfileStories
  include ImastodonSystemHelpers

  context 'unlisted投稿がホームTLに表示される場合' do
    it 'アバターに公開範囲アイコンが表示される'
  end

  context 'public投稿がホームTLに表示される場合' do
    it 'アバターに公開範囲アイコンが表示されない'
  end
end

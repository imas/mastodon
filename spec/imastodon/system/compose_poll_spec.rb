# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '投稿小窓の投票', :js, type: :system do
  include ProfileStories
  include ImastodonSystemHelpers

  context '投稿小窓を開いた場合' do
    before do
      login_and_visit_spa
      within('nav') { click_on frontend_translations('tabs_bar.publish') }
    end

    it '投票ボタンが表示されない' do
      within('form[role="dialog"]') do
        expect(page).to have_button(frontend_translations('compose.publish'))
        expect(page).to have_no_button(frontend_translations('poll_button.add_poll'))
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /settings/favourite_tags', type: :request do
  let!(:user) { Fabricate(:user) }

  describe 'GET /settings/favourite_tags' do
    context 'when signed in' do
      before { sign_in user }

      it 'returns http success' do
        get settings_favourite_tags_path

        expect(response).to have_http_status(:success)
      end

      context 'when the user has favourite tags' do
        before { Fabricate(:favourite_tag, account: user.account, name: 'imastodon') }

        it 'renders icons on the edit and delete links' do
          get settings_favourite_tags_path

          page = Capybara.string(response.body)
          expect(page).to have_css('table a[href$="/edit"] svg path')
          expect(page).to have_css('table a[data-method="delete"] svg path')
        end
      end
    end

    context 'when not signed in' do
      it 'redirects to sign in page' do
        get settings_favourite_tags_path

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end

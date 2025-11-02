# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /settings/favourite_tags/:id/edit', type: :request do
  let!(:user) { Fabricate(:user) }
  let!(:favourite_tag) { Fabricate(:favourite_tag, account: user.account) }

  describe 'GET /settings/favourite_tags/:id/edit' do
    context 'when signed in' do
      before { sign_in user }

      context 'when the favourite tag is found' do
        it 'returns http success' do
          get edit_settings_favourite_tag_path(favourite_tag)

          expect(response).to have_http_status(:success)
        end
      end

      context 'when the favourite tag is not found' do
        it 'returns not found status' do
          get edit_settings_favourite_tag_path(id: 0)

          expect(response).to have_http_status(:missing)
        end
      end
    end

    context 'when not signed in' do
      it 'redirects to sign in page' do
        get edit_settings_favourite_tag_path(favourite_tag)

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end

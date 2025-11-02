# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'DELETE /settings/favourite_tags/:id', type: :request do
  let!(:user) { Fabricate(:user) }
  let!(:favourite_tag) { Fabricate(:favourite_tag, account: user.account, name: 'dummy_tag') }

  describe 'DELETE /settings/favourite_tags/:id' do
    context 'when signed in' do
      before { sign_in user }

      it 'destroys the favourite tag and redirects' do
        expect { delete settings_favourite_tag_path(favourite_tag) }
          .to change(FavouriteTag, :count).by(-1)

        expect(response).to redirect_to(settings_favourite_tags_path)
      end
    end

    context 'when not signed in' do
      it 'redirects to sign in page' do
        delete settings_favourite_tag_path(favourite_tag)

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end

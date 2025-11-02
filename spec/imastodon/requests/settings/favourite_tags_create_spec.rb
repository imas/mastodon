# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'POST /settings/favourite_tags', type: :request do
  let!(:user) { Fabricate(:user) }
  let(:tag_name) { 'dummy_tag' }
  let(:params) do
    {
      favourite_tag: {
        name: tag_name,
        visibility: 'public',
        order: 1,
      },
    }
  end

  describe 'POST /settings/favourite_tags' do
    context 'when signed in' do
      before { sign_in user }

      it 'creates a favourite tag and redirects' do
        expect { post settings_favourite_tags_path, params: params }
          .to change(FavouriteTag, :count).by(1)

        expect(response).to redirect_to(settings_favourite_tags_path)

        created_tag = FavouriteTag.last
        expect(created_tag.name).to eq(tag_name)
        expect(created_tag.visibility).to eq('public')
        expect(created_tag.order).to eq(1)
        expect(created_tag.account).to eq(user.account)
      end

      context 'when the tag has already been favourite' do
        before do
          Fabricate(:favourite_tag, account: user.account, name: tag_name)
        end

        it 'does not create any tags and renders index template' do
          expect { post settings_favourite_tags_path, params: params }
            .to_not change(FavouriteTag, :count)

          expect(response).to have_http_status(:success)
          expect(response.body).to include('favourite_tags')
        end
      end
    end

    context 'when not signed in' do
      it 'redirects to sign in page' do
        post settings_favourite_tags_path, params: params

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end

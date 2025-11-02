# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PUT /settings/favourite_tags/:id', type: :request do
  let!(:user) { Fabricate(:user) }
  let!(:favourite_tag) { Fabricate(:favourite_tag, account: user.account) }

  describe 'PUT /settings/favourite_tags/:id' do
    context 'when signed in' do
      before { sign_in user }

      context 'when the favourite tag can be updated' do
        let(:params) do
          {
            favourite_tag: {
              name: "dummy_tag_#{favourite_tag.id}",
              visibility: 'unlisted',
              order: 2,
            },
          }
        end

        it 'updates the favourite tag and redirects' do
          expect { put settings_favourite_tag_path(favourite_tag), params: params }
            .to_not change(FavouriteTag, :count)

          expect(response).to redirect_to(settings_favourite_tags_path)

          favourite_tag.reload
          expect(favourite_tag.visibility).to eq('unlisted')
          expect(favourite_tag.order).to eq(2)
          expect(favourite_tag.name).to eq("dummy_tag_#{favourite_tag.id}")
        end
      end

      context 'when the favourite tag cannot be updated because tag has already been registered' do
        let(:tag_name) { 'duplicated' }
        let(:params) do
          {
            favourite_tag: {
              name: tag_name,
              visibility: 'public',
              order: 2,
            },
          }
        end

        before do
          Fabricate(:favourite_tag, account: user.account, name: 'duplicated')
        end

        it 'does not update any tags and renders edit template' do
          put settings_favourite_tag_path(favourite_tag), params: params

          expect(response).to have_http_status(:success)
          expect(response.body).to include('favourite_tag')
        end
      end
    end

    context 'when not signed in' do
      it 'redirects to sign in page' do
        put settings_favourite_tag_path(favourite_tag)

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end

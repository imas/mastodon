require 'rails_helper'

RSpec.describe Api::V1::FavouriteTagsController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { double acceptable?: true, resource_owner_id: user.id }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end
  
  describe 'POST #create' do
    let(:tag_name) { 'dummy_tag' }
    let!(:tag) { Fabricate(:tag, name: tag_name) }

    it 'create the favourite tag' do
      expect {
        post :create, params: { tag: tag_name, visibility: 'public' }
      }.to change(FavouriteTag, :count).by(1)
      expect(JSON.parse(response.body, symbolize_names: true).map! {|item|
        item.except(:id)
      }).to eq ([{ :name => tag_name, :visibility => 'public' }])
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    context 'when the tag has already been favourite.' do
      before do
        post :create, params: { tag: tag_name, visibility: 'public' }
      end

      context 'when the tag has the same visibility as already been favourite one.' do
        before do
          post :create, params: { tag: tag_name, visibility: 'public' }
        end

        it 'returns http 409' do
          expect(response).to have_http_status(:conflict)
        end
      end

      context 'when the tag has the different visibility as already been favourite one.' do
        it 'should destroy the old one, create the new one and should render index template' do
          expect {
            post :create, params: { tag: tag_name, visibility: 'unlisted' }
          }.not_to change(FavouriteTag, :count)
          expect(JSON.parse(response.body, symbolize_names: true).map! {|item|
            item.except(:id)
          }).to eq ([{ :name => tag_name, :visibility => 'unlisted' }])
        end

        it 'returns http success' do
          expect(response).to have_http_status(:success)
        end
      end
    end
  end
  
  describe 'DELETE #destroy' do
    let!(:tag) { Fabricate(:tag, name: 'dummy_tag') }
    let!(:favourite_tag) { Fabricate(:favourite_tag, account: user.account, tag: tag) }

    it 'destroy the favourite tag' do
      delete :destroy, params: { tag: favourite_tag.name }
      expect(FavouriteTag.count).to eq 0
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end
end

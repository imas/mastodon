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

    context 'when the tag is a new favourite tag' do
      it 'create a new favourite tag and returns http success' do
        expect {
          post :create, params: { tag: tag_name, visibility: 'public' }
        }.to change(FavouriteTag, :count).by(1)
        expect(JSON.parse(response.body, symbolize_names: true).map! {|item|
          item.except(:id)
        }).to eq ([{ name: tag_name, visibility: 'public' }])
        expect(response).to have_http_status(:success)
      end
    end

    context 'when the tag has already been favourite.' do
      before do
        Fabricate(:favourite_tag, account: user.account, tag: tag)
      end
      
      it 'does not create new favourite_tag and returns http 409' do
        expect {
          post :create, params: { tag: tag_name, visibility: 'public' }
        }.not_to change(FavouriteTag, :count)
        expect(response).to have_http_status(:conflict)
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:tag_name) { 'dummy_tag' }
    let!(:tag) { Fabricate(:tag, name: tag_name) }
    
    before do
      Fabricate(:favourite_tag, account: user.account, tag: tag)
    end

    context 'when try to destroy the favourite tag' do
      it 'destroy the favourite tag and returns http success' do
        delete :destroy, params: { tag: tag_name }
        expect(FavouriteTag.count).to eq 0
        expect(response).to have_http_status(:success)
      end
    end
    
    context 'when try to destroy an unregistered tag' do
      it 'returns http 404' do
        delete :destroy, params: { tag: 'unregistered' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
  
  describe 'PUT #update' do
    let(:tag_name) { 'dummy_tag' }
    let!(:tag) { Fabricate(:tag, name: tag_name) }
    
    before do
      Fabricate(:favourite_tag, account: user.account, tag: tag)
    end
    
    context 'when try to change the visibility setting of a registered tag' do
      it 'changes the visibility setting and returns http success' do
        put :update, params: { tag: tag_name, visibility: 'unlisted' }
        expect(FavouriteTag.count).to eq 1
        expect(JSON.parse(response.body, symbolize_names: true).map! {|item|
          item.except(:id)
        }).to eq ([{ name: tag_name, visibility: 'unlisted' }])
        expect(response).to have_http_status(:success)
      end
    end
    
    context 'when try to change the visibility setting of an unregistered tag' do
      it 'changes the visibility setting and returns http 404' do
        put :update, params: { tag: 'unregistered', visibility: 'unlisted' }
        expect(FavouriteTag.count).to eq 1
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end

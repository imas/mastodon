# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Settings::FavouriteTagsController, type: :controller do
  render_views

  before do
    sign_in user, scope: :user
  end

  let!(:user) { Fabricate(:user) }

  describe 'GET #index' do
    before do
      get :index
    end

    it 'assigns @favourite_tag' do
      expect(assigns(:favourite_tag)).to be_a FavouriteTag
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    let!(:favourite_tag) { Fabricate(:favourite_tag, account: user.account) }

    context 'when the favourite tag is found.' do
      before do
        get :edit, params: { id: favourite_tag.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'assigns @favourite_tag' do
        expect(assigns(:favourite_tag)).to be_a FavouriteTag
        expect(assigns(:favourite_tag)).to eq(favourite_tag)
      end
    end

    context 'when the favourite tag is not found.' do
      before do
        get :edit, params: { id: 0 }
      end

      it 'returns not found status' do
        expect(response).to have_http_status(:missing)
      end
    end
  end

  describe 'POST #create' do
    subject { post :create, params: params }

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

    it 'after create, favourite tag' do
      expect { subject }.to change(FavouriteTag, :count).by(1)
      expect(response).to redirect_to(settings_favourite_tags_path)
    end

    context 'when the tag has already been favourite.' do
      before do
        Fabricate(:favourite_tag, account: user.account, name: tag_name)
      end

      it 'does not create any tags and should render index template' do
        expect { subject }.to_not change(FavouriteTag, :count)
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'PUT #update' do
    let!(:favourite_tag) { Fabricate(:favourite_tag, account: user.account) }

    context 'The favourite tag can update.' do
      subject { put :update, params: params }

      let(:params) do
        {
          id: favourite_tag.id,
          favourite_tag: {
            name: "dummy_tag_#{favourite_tag.id}",
            visibility: 'unlisted',
            order: 2,
          },
        }
      end

      it 'after update, favourite tag' do
        expect { subject }.to_not change(FavouriteTag, :count)
        expect(assigns(:favourite_tag).visibility).to eq('unlisted')
        expect(assigns(:favourite_tag).order).to eq(2)
        expect(assigns(:favourite_tag).name).to eq("dummy_tag_#{favourite_tag.id}")
        expect(response).to redirect_to(settings_favourite_tags_path)
      end
    end

    context 'The favourite tag could not update, because tag has already been registered.' do
      subject { put :update, params: params }

      let(:tag_name) { 'duplicated' }
      let(:params) do
        {
          id: favourite_tag.id,
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

      it 'does not update any tags and should render edit template' do
        subject
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE #destroy' do
    subject { delete :destroy, params: params }

    let!(:favourite_tag) { Fabricate(:favourite_tag, account: user.account, name: 'dummy_tag') }
    let(:params) do
      {
        id: favourite_tag.id,
      }
    end

    it 'after destroy, favourite tag' do
      expect { subject }.to change(FavouriteTag, :count).by(-1)
      expect(response).to redirect_to(settings_favourite_tags_path)
    end
  end
end

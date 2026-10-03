# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Deliverability probe sign-up (imastodon)', type: :request do
  let(:probe_username) { 'bp8d064b8ce361cf9f' }
  let(:probe_reason) { 'Automated protocol deliverability probe' }

  before { Setting.registrations_mode = 'approved' }

  describe 'POST /api/v1/accounts' do
    subject do
      post '/api/v1/accounts', headers: { 'Authorization' => "Bearer #{token.token}" }, params: { username: username, reason: reason, password: '12345678', email: 'probe@example.com', agreement: 'true' }
    end

    let(:token) { Fabricate(:client_credentials_token, application: Fabricate(:application), scopes: 'read write') }

    context 'when the username is bp + 16 hex digits and the reason is the probe text' do
      let(:username) { probe_username }
      let(:reason) { probe_reason }

      it 'returns 200 without creating an account' do
        expect { subject }
          .to not_change(User, :count)
          .and not_change(Account, :count)

        expect(response).to have_http_status(200)
      end

      it 'returns a dummy token response shaped like a real sign-up'
    end

    context 'when only the username matches' do
      let(:username) { probe_username }
      let(:reason) { 'アイマスが好きです' }

      it 'creates an account with the probe-like username' do
        expect { subject }
          .to change(User, :count).by(1)

        expect(Account.find_local(probe_username)).to be_present
      end
    end

    context 'when only the reason matches' do
      let(:username) { 'fuyuko' }
      let(:reason) { probe_reason }

      it 'creates an account with the probe reason' do
        expect { subject }
          .to change(User, :count).by(1)

        expect(Account.find_local('fuyuko')).to be_present
      end
    end

    context 'when the hex part of the username is not 16 digits' do
      let(:username) { 'bp8d064b8ce361cf9f0' }
      let(:reason) { probe_reason }

      it 'creates an account with the 17-digit username' do
        expect { subject }
          .to change(User, :count).by(1)

        expect(Account.find_local('bp8d064b8ce361cf9f0')).to be_present
      end
    end
  end
end

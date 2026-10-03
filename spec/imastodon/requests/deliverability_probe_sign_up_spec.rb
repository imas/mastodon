# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Deliverability probe sign-up (imastodon)', type: :request do
  describe 'POST /api/v1/accounts' do
    context 'when the username is bp + 16 hex digits and the reason is the probe text' do
      it 'returns 200 without creating an account'
    end

    context 'when only the username matches' do
      it 'creates an account with the probe-like username'
    end

    context 'when only the reason matches' do
      it 'creates an account with the probe reason'
    end

    context 'when the hex part of the username is not 16 digits' do
      it 'creates an account with the 17-digit username'
    end
  end
end

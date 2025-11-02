# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::ErrorHandling do
  before do
    stub_const('FakeService', Class.new)
  end

  controller(Api::BaseController) do
    def failure
      FakeService.new
    end
  end

  describe 'error handling' do
    before do
      routes.draw { get 'failure' => 'api/base#failure' }
    end

    {
      ActiveRecord::RecordInvalid => 422,
      ActiveRecord::RecordNotFound => 404,
      ActiveRecord::RecordNotUnique => 422,
      Date::Error => 422,
      HTTP::Error => 503,
      Mastodon::InvalidParameterError => 400,
      Mastodon::NotPermittedError => 403,
      Mastodon::RaceConditionError => 503,
      Mastodon::RateLimitExceededError => 429,
      Mastodon::UnexpectedResponseError => 503,
      Mastodon::ValidationError => 422,
      OpenSSL::SSL::SSLError => 503,
      Seahorse::Client::NetworkingError => 503,
      Stoplight::Error::RedLight => 503,
    }.each do |error, code|
      it "Handles error class of #{error}" do
        # アイマストドンがaws-sdk-ssmを使っているためロード順の関係でこれが必要
        # aws-sdkの本物のSeahorse::Client::NetworkingErrorクラスは第一引数が必要
        # 本家はs3が有効な場合にのみaws-sdk-s3をrequireし、そうでない場合は単にStandardErrorを継承したダミーの
        # Seahorse::Client::NetworkingErrorクラスを定義しているため、s3有効でないテスト環境下では
        # https://github.com/mastodon/mastodon/blob/03210085b7481568cc507f088144aaf1dae73c88/spec/controllers/concerns/api/error_handling_spec.rb
        # のモックで成立するが、アイマストドンはaws-sdk-ssmを常に使っているためs3有効でないテスト環境下でも
        # 本物のSeahorse::Client::NetworkingErrorクラスが常にロードされるため、下記のように引数付きでインスタンス化する必要がある。
        exception_instance = if error.name == 'Seahorse::Client::NetworkingError'
                               # Seahorse::Client::NetworkingError requires an Error object
                               error.new(StandardError.new('test error'))
                             else
                               error.new
                             end

        allow(FakeService)
          .to receive(:new)
          .and_raise(exception_instance)

        get :failure

        expect(response)
          .to have_http_status(code)
        expect(FakeService)
          .to have_received(:new)
      end
    end
  end
end

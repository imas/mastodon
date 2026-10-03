# frozen_string_literal: true

module DeliverabilityProbeRejectionConcern
  extend ActiveSupport::Concern

  PROBE_USERNAME_REGEX = /\Abp[0-9a-f]{16}\z/
  PROBE_REASON = 'Automated protocol deliverability probe'

  private

  def reject_deliverability_probe
    return unless PROBE_USERNAME_REGEX.match?(params[:username].to_s) && params[:reason] == PROBE_REASON

    response = Doorkeeper::OAuth::TokenResponse.new(dummy_access_token)

    headers.merge!(response.headers)
    render json: response.body, status: response.status
  end

  # AppSignUpService と同じ属性で組み立て、保存はしない。
  # validate を通すと、保存時と同じ手順でトークン文字列が生成される
  def dummy_access_token
    Doorkeeper::AccessToken.new(
      application: doorkeeper_token.application,
      scopes: doorkeeper_token.application.scopes,
      expires_in: Doorkeeper.configuration.access_token_expires_in,
      use_refresh_token: Doorkeeper.configuration.refresh_token_enabled?,
      created_at: Time.now.utc
    ).tap(&:validate)
  end
end

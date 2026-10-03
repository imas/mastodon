# frozen_string_literal: true

module DeliverabilityProbeRejectionConcern
  extend ActiveSupport::Concern

  PROBE_USERNAME_REGEX = /\Abp[0-9a-f]{16}\z/
  PROBE_REASON = 'Automated protocol deliverability probe'

  private

  def reject_deliverability_probe
    head 200 if PROBE_USERNAME_REGEX.match?(params[:username].to_s) && params[:reason] == PROBE_REASON
  end
end

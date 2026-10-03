# frozen_string_literal: true

module DeliverabilityProbeRejectionConcern
  extend ActiveSupport::Concern

  PROBE_REASON = 'Automated protocol deliverability probe'

  private

  def reject_deliverability_probe
    head 200 if params[:reason] == PROBE_REASON
  end
end

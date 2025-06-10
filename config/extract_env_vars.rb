# frozen_string_literal: true

require 'aws-sdk-ssm'
require 'active_support/core_ext/object/blank'

def extract_env_vars(region, prefix)
  client = Aws::SSM::Client.new(region: region)
  next_token = nil

  loop do
    response = client.get_parameters_by_path(
      {
        path: prefix,
        with_decryption: true,
        next_token: next_token,
      }
    )

    response.parameters.each do |parameter|
      env_name = parameter.name.split('/').last
      ENV[env_name] = parameter.value
    end

    next_token = response.next_token
    break if next_token.blank?
  end
end

region = ENV.fetch('PARAMETER_STORE_REGION', nil)
prefix = ENV.fetch('PARAMETER_STORE_PREFIX', nil)

extract_env_vars(region, prefix) if region.present? && prefix.present?

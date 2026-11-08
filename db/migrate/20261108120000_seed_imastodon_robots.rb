# frozen_string_literal: true

class SeedImastodonRobots < ActiveRecord::Migration[8.1]
  class Setting < ApplicationRecord; end

  ROBOTS = <<~TXT
    User-agent: GPTBot
    User-agent: ExaSearchBot
    User-agent: meta-externalagent
    Disallow: /

    User-agent: *
    Disallow: /media_proxy/
    Disallow: /interact/
    Disallow: /api/v1/instance/domain_blocks
    Disallow: /auth/
    Disallow: /users/
    Disallow: /api/v1/timelines/
    Disallow: /api/v1/trends/
  TXT

  def up
    Setting.reset_column_information

    Setting.upsert_all(
      [
        { var: 'override_robots', value: true.to_yaml },
        { var: 'custom_robots', value: ROBOTS.to_yaml },
      ],
      unique_by: index_exists?(:settings, [:thing_type, :thing_id, :var]) ? [:thing_type, :thing_id, :var] : :var
    )
  end

  def down; end
end

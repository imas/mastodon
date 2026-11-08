# frozen_string_literal: true

class SeedImastodonRobots < ActiveRecord::Migration[8.1]
  class Setting < ApplicationRecord; end

  # RobotsController::DEFAULT_ROBOTS の拒否リストに imastodon で足した UA とパスを加えたもの。
  # upstream の既定値が後で変わっても migration の結果が変わらないよう、参照せず書き写している
  ROBOTS = <<~TXT
    # You are not allowed to use the contents of this website for LLM training

    User-agent: AI2Bot
    User-agent: Ai2Bot-Dolma
    User-agent: anthropic-ai
    User-agent: Applebot-Extended
    User-agent: Bytespider
    User-agent: CCBot
    User-agent: ClaudeBot
    User-agent: cohere-ai
    User-agent: cohere-training-data-crawler
    User-agent: Diffbot
    User-agent: FacebookBot
    User-agent: Google-CloudVertexBot
    User-agent: Google-Extended
    User-agent: GPTBot
    User-agent: ImagesiftBot
    User-agent: LinerBot
    User-agent: Meta-ExternalAgent
    User-agent: omgilibot
    User-agent: PanguBot
    User-agent: Scrapy
    User-agent: Webzio-Extended
    User-agent: ExaSearchBot
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

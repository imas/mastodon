# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('db', 'migrate', '20261108120000_seed_imastodon_robots.rb')

RSpec.describe SeedImastodonRobots do
  let(:migration) { described_class.new }

  # Setting はキャッシュから返すため、migration が DB に書いた値はダミーの Setting クラスで直接読む
  def stored(var)
    value = described_class::Setting.find_by(var: var)&.value
    YAML.safe_load(value) if value
  end

  context '管理画面で robots.txt を上書きしていないとき' do
    it 'robots.txt の上書きを有効にする' do
      migration.up
      expect(stored('override_robots')).to be true
    end

    it 'imastodon で拒否していた UA とパスを書き込む' do
      migration.up
      expect(stored('custom_robots').lines(chomp: true)).to include(
        'User-agent: ExaSearchBot',
        'Disallow: /interact/',
        'Disallow: /api/v1/instance/domain_blocks',
        'Disallow: /auth/',
        'Disallow: /users/',
        'Disallow: /api/v1/timelines/',
        'Disallow: /api/v1/trends/'
      )
    end

    it 'upstream の既定で拒否している AI クローラーも書き込む' do
      migration.up
      upstream_agents = RobotsController::DEFAULT_ROBOTS.lines(chomp: true).grep(/\AUser-agent: (?!\*)/)
      expect(stored('custom_robots').lines(chomp: true)).to include(*upstream_agents)
    end
  end

  context '管理画面で robots.txt を既に設定しているとき' do
    it '設定を変えない' do
      Setting.override_robots = false
      Setting.custom_robots = "User-agent: *\nDisallow: /secret/\n"

      migration.up

      expect(stored('override_robots')).to be false
      expect(stored('custom_robots')).to eq "User-agent: *\nDisallow: /secret/\n"
    end
  end

  # Historical data migration test の投入データのように、id を明示して入れた行があると連番が追いつかない
  context 'settings の連番が既存の id より遅れているとき' do
    it '連番を追いつかせて書き込む' do
      next_id = described_class::Setting.connection.select_value("SELECT nextval('settings_id_seq')")
      described_class::Setting.create!(id: next_id + 1, var: 'site_title', value: "--- imastodon\n")

      migration.up

      expect(stored('override_robots')).to be true
    end
  end
end

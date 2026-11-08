# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('db', 'migrate', '20261108120000_seed_imastodon_robots.rb')

RSpec.describe SeedImastodonRobots do
  let(:migration) { described_class.new }

  context '管理画面で robots.txt を上書きしていないとき' do
    it 'robots.txt の上書きを有効にする' do
      migration.up
      expect(Setting.override_robots).to be true
    end

    it 'imastodon で拒否していた UA とパスを書き込む'
    it 'upstream の既定で拒否している AI クローラーも書き込む'
  end

  context '管理画面で robots.txt を既に設定しているとき' do
    it '設定を変えない'
  end
end

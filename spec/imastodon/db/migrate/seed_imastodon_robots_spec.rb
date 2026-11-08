# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SeedImastodonRobots' do
  context '管理画面で robots.txt を上書きしていないとき' do
    it 'robots.txt の上書きを有効にする'
    it 'imastodon で拒否していた UA とパスを書き込む'
    it 'upstream の既定で拒否している AI クローラーも書き込む'
  end

  context '管理画面で robots.txt を既に設定しているとき' do
    it '設定を変えない'
  end
end

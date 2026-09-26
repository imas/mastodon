# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('lib', 'imastodon', 'ja_im_candidates')

RSpec.describe JaImCandidates do
  describe '#candidates' do
    it '言い換える語を ja が含み、ja-IM に無いキーを返す' do
      finder = described_class.new(
        en_messages: { 'status.delete' => 'Delete post' },
        ja_messages: { 'status.delete' => '投稿を削除' },
        ja_im_messages: {}
      )

      expect(finder.candidates.map(&:key)).to eq ['status.delete']
    end

    it '語を置き換えた訳文を言い換え案として返す' do
      finder = described_class.new(
        en_messages: { 'status.reblogs.empty' => 'No one has boosted this post yet.' },
        ja_messages: { 'status.reblogs.empty' => 'まだ誰もこの投稿をブーストしていません。' },
        ja_im_messages: {}
      )

      expect(finder.candidates.first.suggestion).to eq 'まだ誰もこのあふぅをわかるわしていません。'
    end

    it 'ja-IM で言い換え済みのキーは返さない' do
      finder = described_class.new(
        en_messages: { 'status.delete' => 'Delete post' },
        ja_messages: { 'status.delete' => '投稿を削除' },
        ja_im_messages: { 'status.delete' => 'あふぅを削除' }
      )

      expect(finder.candidates).to eq []
    end

    it '言い換える語を含まないキーは返さない' do
      finder = described_class.new(
        en_messages: { 'status.copy' => 'Copy link' },
        ja_messages: { 'status.copy' => 'リンクをコピー' },
        ja_im_messages: {}
      )

      expect(finder.candidates).to eq []
    end

    it '除外リストにあるキーは返さない' do
      finder = described_class.new(
        en_messages: { 'status.delete' => 'Delete post' },
        ja_messages: { 'status.delete' => '投稿を削除' },
        ja_im_messages: {},
        ignored_keys: ['status.delete']
      )

      expect(finder.candidates).to eq []
    end

    it '長い語を優先して置き換える' do
      finder = described_class.new(
        en_messages: { 'keyboard_shortcuts.home' => 'Open home timeline' },
        ja_messages: { 'keyboard_shortcuts.home' => 'ホームタイムラインを開く' },
        ja_im_messages: {}
      )

      expect(finder.candidates.first.suggestion).to eq 'オフィスを開く'
    end

    it 'en に無いキーは返さない' do
      finder = described_class.new(
        en_messages: {},
        ja_messages: { 'status.removed_key' => '投稿を削除' },
        ja_im_messages: {}
      )

      expect(finder.candidates).to eq []
    end
  end

  describe '#coverage' do
    it '語ごとに ja で含むキーの数と、言い換え済み・除外済みの数を返す' do
      finder = described_class.new(
        en_messages: { 'a' => 'A', 'b' => 'B', 'c' => 'C', 'd' => 'D' },
        ja_messages: { 'a' => '投稿を削除', 'b' => '投稿を編集', 'c' => '投稿を固定', 'd' => 'ブーストを取り消す' },
        ja_im_messages: { 'a' => 'あふぅを削除' },
        ignored_keys: ['b']
      )

      expect(finder.coverage['投稿']).to eq({ total: 3, overridden: 1, ignored: 1 })
      expect(finder.coverage['ブースト']).to eq({ total: 1, overridden: 0, ignored: 0 })
    end
  end

  describe '.load_json' do
    it 'en / ja / ja-IM の JSON を読み込む' do
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, 'en.json'), { 'status.delete' => 'Delete' }.to_json)
        File.write(File.join(dir, 'ja.json'), { 'status.delete' => '投稿を削除' }.to_json)
        File.write(File.join(dir, 'ja-IM.json'), { 'status.delete' => 'あふぅを削除' }.to_json)

        expect(described_class.load_json(dir)).to eq(
          en_messages: { 'status.delete' => 'Delete' },
          ja_messages: { 'status.delete' => '投稿を削除' },
          ja_im_messages: { 'status.delete' => 'あふぅを削除' }
        )
      end
    end
  end

  describe '.load_yml' do
    it 'ロケールごとに <locale>.yml と *.<locale>.yml をまとめて平坦なハッシュで読み込む' do
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, 'en.yml'), { 'en' => { 'statuses' => { 'title' => 'Posts' } } }.to_yaml)
        File.write(File.join(dir, 'simple_form.en.yml'), { 'en' => { 'simple_form' => { 'labels' => { 'text' => 'Post' } } } }.to_yaml)
        File.write(File.join(dir, 'ja.yml'), { 'ja' => { 'statuses' => { 'title' => '投稿' } } }.to_yaml)
        File.write(File.join(dir, 'simple_form.ja.yml'), { 'ja' => { 'simple_form' => { 'labels' => { 'text' => '投稿' } } } }.to_yaml)
        File.write(File.join(dir, 'ja-IM.yml'), { 'ja-IM' => { 'statuses' => { 'title' => 'あふぅ' } } }.to_yaml)

        expect(described_class.load_yml(dir)).to eq(
          en_messages: { 'statuses.title' => 'Posts', 'simple_form.labels.text' => 'Post' },
          ja_messages: { 'statuses.title' => '投稿', 'simple_form.labels.text' => '投稿' },
          ja_im_messages: { 'statuses.title' => 'あふぅ' }
        )
      end
    end
  end

  describe '除外リスト' do
    it 'en に存在するキーだけを持つ' do
      ignored = described_class.load_ignored
      json_en = described_class.load_json(Rails.root.join('app', 'javascript', 'mastodon', 'locales'))[:en_messages]
      yml_en = described_class.load_yml(Rails.root.join('config', 'locales'))[:en_messages]

      expect(ignored[:json].reject { |key| json_en.key?(key) }).to eq []
      expect(ignored[:yml].reject { |key| yml_en.key?(key) }).to eq []
    end
  end
end

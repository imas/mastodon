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

    it '長い語を優先して置き換える'
    it 'ja に無いキーは返さない'
  end

  describe '#coverage' do
    it '語ごとに ja で含むキーの数と ja-IM で言い換え済みの数を返す'
  end

  describe '.load_json' do
    it 'en / ja / ja-IM の JSON を読み込む'
  end

  describe '.load_yml' do
    it 'ロケールごとに <locale>.yml と *.<locale>.yml をまとめて平坦なハッシュで読み込む'
  end

  describe '除外リスト' do
    it 'en に存在するキーだけを持つ'
  end
end

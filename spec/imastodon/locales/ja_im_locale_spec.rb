# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'I18n' do
  def flatten_translations(hash, prefix = nil)
    hash.each_with_object({}) do |(key, value), result|
      path = [prefix, key].compact.join('.')

      if value.is_a?(Hash)
        result.merge!(flatten_translations(value, path))
      else
        result[path] = value
      end
    end
  end

  def translations_for(locale)
    flatten_translations(I18n.backend.translations(do_init: true).fetch(locale))
  end

  describe 'ja-IM ロケール' do
    it 'ja-IM で言い換えているキーは ja-IM の訳文になる' do
      expect(I18n.t('accounts.posts_tab_heading', locale: :'ja-IM')).to eq 'あふぅ'
    end

    it 'ja-IM に無いキーは ja の訳文になる' do
      expect(I18n.t('about.contact_missing', locale: :'ja-IM')).to eq '未設定'
    end
  end

  %w(ja-IM simple_form.ja-IM activerecord.ja-IM).each do |name|
    describe "config/locales/#{name}.yml" do
      let(:ja_im) { flatten_translations(YAML.load_file(Rails.root.join('config', 'locales', "#{name}.yml")).fetch('ja-IM')) }

      it 'en に存在しないキーを持たない' do
        en = translations_for(:en)

        expect(ja_im.keys.reject { |key| en.key?(key) }).to eq []
      end

      it 'ja と同じ訳文のキーを持たない' do
        ja = translations_for(:ja)

        expect(ja_im.select { |key, value| ja[key] == value }.keys).to eq []
      end

      it '訳文の変数が ja と一致する'
    end
  end
end

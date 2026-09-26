# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'I18n' do
  describe 'ja-IM ロケール' do
    it 'ja-IM で言い換えているキーは ja-IM の訳文になる'
    it 'ja-IM に無いキーは ja の訳文になる'
  end

  %w(ja-IM simple_form.ja-IM activerecord.ja-IM).each do |name|
    describe "config/locales/#{name}.yml" do
      it 'en に存在しないキーを持たない'
      it 'ja と同じ訳文のキーを持たない'
      it '訳文の変数が ja と一致する'
    end
  end
end

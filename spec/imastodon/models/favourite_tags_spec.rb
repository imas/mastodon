# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FavouriteTag, type: :model do
  describe 'validation' do
    let(:account) { Fabricate :account }

    describe 'visibility' do
      it '値が0(public)から3(direct)ならvalid' do
        expect(described_class.new(account: account, name: 'tag', visibility: 0)).to be_valid
        expect(described_class.new(account: account, name: 'tag', visibility: 1)).to be_valid
        expect(described_class.new(account: account, name: 'tag', visibility: 2)).to be_valid
        expect(described_class.new(account: account, name: 'tag', visibility: 3)).to be_valid
      end

      it '値が4(enum上で未定義)ならArgumentErrorをraise' do
        expect { described_class.new(account: account, name: 'tag', visibility: 4) }.to raise_error(ArgumentError)
      end
    end

    describe 'name' do
      it 'nameは大文字小文字混ざりで作成できる' do
        # Tagモデルは途中から英字が小文字に正規化されるようになったが、お気に入りタグは大文字小文字混ざりで作成したいという要望があるため
        favourite_tag = described_class.new(account: account, name: 'Test', visibility: 0)

        expect(favourite_tag).to be_valid
      end

      it 'お気に入りタグを作成しようとしたとき、そのタグの名前が不正ならinvalid' do
        expect(described_class.new(account: account, name: 'test tag', visibility: 0)).to_not be_valid
      end

      it '同じ名前でも公開範囲が異なるならばvalid' do
        Fabricate(:favourite_tag, account: account, name: 'test', visibility: :public)

        duplicated = described_class.new(account: account, visibility: :unlisted, order: 100, name: 'test')
        expect(duplicated).to be_valid
      end

      it '同じ名前、同じ公開範囲で既にお気に入りタグを作成しているならばinvalid' do
        Fabricate(:favourite_tag, account: account, name: 'test')

        duplicated = described_class.new(account: account, visibility: :public, order: 100, name: 'test')
        expect(duplicated).to_not be_valid
      end
    end
  end

  describe 'deletion' do
    let!(:favourite_tag) { Fabricate(:favourite_tag) }

    it 'delete favourite_tag' do
      expect { favourite_tag.destroy }.to change(described_class, :count).by(-1)
      expect { favourite_tag.destroy }.to_not change(described_class, :count)
    end
  end

  describe 'scopes' do
    describe 'with_order' do
      let(:account) { Fabricate(:account, username: 'favourite') }

      it 'returns an array of recent favourite tags ordered by order and id' do
        specifieds = [
          Fabricate(:favourite_tag, account: account, name: 'test1', order: 10),
          Fabricate(:favourite_tag, account: account, name: 'test2', order: 11),
          Fabricate(:favourite_tag, account: account, name: 'test3', order: 10),
        ]
        expect(account.favourite_tags.with_order.limit(3)).to eq(
          [
            specifieds[1],
            specifieds[0],
            specifieds[2],
          ]
        )
      end
    end
  end

  describe 'expect to_json_for_api' do
    let(:account) { Fabricate :account }
    let!(:favourite_tag) { Fabricate(:favourite_tag, account: account, name: 'test_tag') }

    it 'expect to_json_for_api' do
      json = favourite_tag.to_json_for_api
      expect(json[:id]).to eq favourite_tag.id
      expect(json[:name]).to eq 'test_tag'
      expect(json[:visibility]).to eq 'public'
    end
  end

  describe 'migrate_tag_name!' do
    it 'モデルのnameカラムに値が入っていない場合は関連付けのtagからnameをコピーする' do
      account = Fabricate(:account)
      tag = Tag.create!(name: 'tag')
      favourite_tag = described_class.new(account: account, tag: tag, visibility: :public, name: nil)
      favourite_tag.save!(validate: false)

      expect(favourite_tag.name).to be_nil

      favourite_tag.migrate_tag_name!

      expect(favourite_tag.name).to eq('tag')
    end

    it 'モデルのnameカラムに値が入っている場合は変更しない' do
      account = Fabricate(:account)
      tag = Tag.create!(name: 'hoge_tag')
      favourite_tag = described_class.new(account: account, tag: tag, visibility: :public, name: 'tag')
      favourite_tag.save!

      expect(favourite_tag.name).to eq('tag')

      favourite_tag.migrate_tag_name!

      expect(favourite_tag.name).to eq('tag')
    end
  end
end

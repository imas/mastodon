# frozen_string_literal: true
require 'rails_helper'

RSpec.describe FanOutOnWriteService, type: :service do
  let(:author)   { Fabricate(:account, username: 'frederica') }
  let(:alice)    { Fabricate(:user, account: Fabricate(:account, username: 'tachibana')).account }
  let(:follower) { Fabricate(:account, username: 'syuko') }

  subject { described_class.new }

  before do
    alice
    follower.follow!(author)

    ProcessMentionsService.new.call(status)
    ProcessHashtagsService.new.call(status)

    allow(redis).to receive(:publish)

    subject.call(status)
  end

  context 'タグ付きの投稿' do
    let(:body) { 'ふんふんふふーん フレデリカー #hoge #fuga #nyowa' }
    let(:status) { Fabricate(:status, text: body, account: author, visibility: visibility) }

    shared_examples 'LTLに配信される' do
      it '' do
        expect(redis).to have_received(:publish).with('timeline:public', anything).once
        expect(redis).to have_received(:publish).with('timeline:public:local', anything).once
      end
    end

    shared_examples 'LTLに配信されない' do
      it '' do
        expect(redis).not_to have_received(:publish).with('timeline:public', anything)
        expect(redis).not_to have_received(:publish).with('timeline:public:local', anything)
      end
    end

    shared_examples 'tagTLのunauthorizedチャンネルに配信される' do
      it '' do
        status.tags.pluck(:name).each do |tag_name|
          expect(redis).to have_received(:publish).with("timeline:hashtag:#{tag_name.mb_chars.downcase}", anything).once
          expect(redis).to have_received(:publish).with("timeline:hashtag:#{tag_name.mb_chars.downcase}:local", anything).once
        end
      end
    end

    shared_examples 'tagTLのunauthorizedチャンネルに配信されない' do
      it '' do
        status.tags.pluck(:name).each do |tag_name|
          expect(redis).not_to have_received(:publish).with("timeline:hashtag:#{tag_name.mb_chars.downcase}", anything)
          expect(redis).not_to have_received(:publish).with("timeline:hashtag:#{tag_name.mb_chars.downcase}:local", anything)
        end
      end
    end

    shared_examples 'tagTLのauthorizedチャンネルに配信される' do
      it '' do
        status.tags.pluck(:name).each do |tag_name|
          expect(redis).to have_received(:publish).with("timeline:hashtag:#{tag_name.mb_chars.downcase}:authorized", anything).once
          expect(redis).to have_received(:publish).with("timeline:hashtag:#{tag_name.mb_chars.downcase}:authorized:local", anything).once
        end
      end
    end

    shared_examples 'tagTLのauthorizedチャンネルに配信されない' do
      it '' do
        status.tags.pluck(:name).each do |tag_name|
          expect(redis).not_to have_received(:publish).with("timeline:hashtag:#{tag_name.mb_chars.downcase}:authorized", anything)
          expect(redis).not_to have_received(:publish).with("timeline:hashtag:#{tag_name.mb_chars.downcase}:authorized:local", anything)
        end
      end
    end

    context 'public' do
      let(:visibility) { :public }
      it_behaves_like 'LTLに配信される'
      it_behaves_like 'tagTLのunauthorizedチャンネルに配信される'
      it_behaves_like 'tagTLのauthorizedチャンネルに配信される'
    end

    context 'unlisted' do
      let(:visibility) { :unlisted }
      it_behaves_like 'LTLに配信されない'
      it_behaves_like 'tagTLのunauthorizedチャンネルに配信されない'
      it_behaves_like 'tagTLのauthorizedチャンネルに配信される'
    end

    context 'private' do
      let(:visibility) { :private }
      it_behaves_like 'LTLに配信されない'
      it_behaves_like 'tagTLのunauthorizedチャンネルに配信されない'
      it_behaves_like 'tagTLのauthorizedチャンネルに配信されない'
    end

    context 'direct' do
      let(:visibility) { :direct }
      it_behaves_like 'LTLに配信されない'
      it_behaves_like 'tagTLのunauthorizedチャンネルに配信されない'
      it_behaves_like 'tagTLのauthorizedチャンネルに配信されない'
    end

    context 'メンションが含まれる投稿' do
      let(:body) { '@tachibana ヘイヘーイ。 そこのカノジョー、一緒にブラデリカしないかーい？ #hoge #fuga #nyowa' }

      context 'public' do
        let(:visibility) { :public }
        it_behaves_like 'LTLに配信される'
        it_behaves_like 'tagTLのunauthorizedチャンネルに配信される'
        it_behaves_like 'tagTLのauthorizedチャンネルに配信される'
      end

      context 'unlisted' do
        let(:visibility) { :unlisted }
        it_behaves_like 'LTLに配信されない'
        it_behaves_like 'tagTLのunauthorizedチャンネルに配信されない'
        it_behaves_like 'tagTLのauthorizedチャンネルに配信される'
      end

      context 'private' do
        let(:visibility) { :private }
        it_behaves_like 'LTLに配信されない'
        it_behaves_like 'tagTLのunauthorizedチャンネルに配信されない'
        it_behaves_like 'tagTLのauthorizedチャンネルに配信されない'
      end
  
      context 'direct' do
        let(:visibility) { :direct }
        it_behaves_like 'LTLに配信されない'
        it_behaves_like 'tagTLのunauthorizedチャンネルに配信されない'
        it_behaves_like 'tagTLのauthorizedチャンネルに配信されない'
      end
    end

    context '自分以外の投稿へのin_reply_toが設定されている投稿' do
      let(:status) { Fabricate(:status, text: body, account: author, visibility: visibility, in_reply_to_id: Fabricate(:status, account: alice).id) }

      context 'public' do
        let(:visibility) { :public }
        it_behaves_like 'LTLに配信されない'
        it_behaves_like 'tagTLのunauthorizedチャンネルに配信される'
        it_behaves_like 'tagTLのauthorizedチャンネルに配信される'
      end

      context 'unlisted' do
        let(:visibility) { :unlisted }
        it_behaves_like 'LTLに配信されない'
        it_behaves_like 'tagTLのunauthorizedチャンネルに配信されない'
        it_behaves_like 'tagTLのauthorizedチャンネルに配信されない'
      end

      context 'private' do
        let(:visibility) { :private }
        it_behaves_like 'LTLに配信されない'
        it_behaves_like 'tagTLのunauthorizedチャンネルに配信されない'
        it_behaves_like 'tagTLのauthorizedチャンネルに配信されない'
      end
  
      context 'direct' do
        let(:visibility) { :direct }
        it_behaves_like 'LTLに配信されない'
        it_behaves_like 'tagTLのunauthorizedチャンネルに配信されない'
        it_behaves_like 'tagTLのauthorizedチャンネルに配信されない'
      end
    end

    context '自分の投稿へのin_reply_toが設定されている投稿' do
      let(:status) { Fabricate(:status, text: body, account: author, visibility: visibility, in_reply_to_id: Fabricate(:status, account: author).id) }

      context 'public' do
        let(:visibility) { :public }
        it_behaves_like 'LTLに配信される'
        it_behaves_like 'tagTLのunauthorizedチャンネルに配信される'
        it_behaves_like 'tagTLのauthorizedチャンネルに配信される'
      end

      context 'unlisted' do
        let(:visibility) { :unlisted }
        it_behaves_like 'LTLに配信されない'
        it_behaves_like 'tagTLのunauthorizedチャンネルに配信されない'
        it_behaves_like 'tagTLのauthorizedチャンネルに配信される'
      end

      context 'private' do
        let(:visibility) { :private }
        it_behaves_like 'LTLに配信されない'
        it_behaves_like 'tagTLのunauthorizedチャンネルに配信されない'
        it_behaves_like 'tagTLのauthorizedチャンネルに配信されない'
      end
  
      context 'direct' do
        let(:visibility) { :direct }
        it_behaves_like 'LTLに配信されない'
        it_behaves_like 'tagTLのunauthorizedチャンネルに配信されない'
        it_behaves_like 'tagTLのauthorizedチャンネルに配信されない'
      end
    end
  end
end

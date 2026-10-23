# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ja-IMロケール', :js, type: :system do
  include ProfileStories
  include ImastodonSystemHelpers

  context 'ロケールをja-IMに設定した場合' do
    before do
      login_and_visit_spa
      ignore_js_error(/MISSING_TRANSLATION/)
      change_user_locale('ja-IM')
      visit '/'
      wait_for_react
    end

    after do
      change_user_locale('ja')
    end

    it '投稿ボタンのテキストが「あふぅ」である' do
      within('nav') { click_on '新しいあふぅ' }
      within('form[role="dialog"]') do
        expect(page).to have_button('あふぅ', type: 'submit')
      end
    end

    it 'ブーストボタンが「わかるわか引用」と表示される' do
      status = Fabricate(:status, account: bob.account, text: 'わかるわテスト投稿', visibility: :public)
      FeedManager.instance.push_to_home(bob.account, status)
      visit '/home'
      wait_for_react
      # リデザイン版のブーストボタンは見えないラベル要素を aria-labelledby で参照していて、
      # Capybara の have_button はそれを名前として解決しない
      boost_button = find('article[data-id] button[aria-haspopup="menu"][aria-pressed]')
      expect(page).to have_css("##{boost_button['aria-labelledby']}", text: 'わかるわか引用', visible: :hidden)
    end

    it '投稿小窓のタイトルが「新しいあふぅ」、本文欄のプレースホルダが「もう時間がないんです！」である'

    it '公開範囲メニューの見出しが「公開範囲」、選択肢が「公開資料」「私的資料」「楽屋には発言しない」である'

    it '検索結果に出さないようにすると、公開範囲のボタンが「社内資料」になる'

    it '閲覧注意のトグルが「早苗さんに見つからないようにする」、入力欄が「ζ\'ヮ\')ζ＜まえせつ」である'

    it '返信の投稿小窓のタイトルが「Re:あふぅ」である'

    it 'メッセージに切り替えると、タイトルが「新しい機密資料」、ヒントが「指定した同僚だけに公開。暗号化はされません」、送信ボタンが「あふぅ」になる'

    it 'アカウントカードの「⋯」メニューに「理由あってブロック！」「だまっとけ☆リスト」がある'
  end
end

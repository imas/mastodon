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

    def open_composer
      within('nav') { click_on '新しいあふぅ' }
      expect(page).to have_css('form[role="dialog"]')
    end

    it '投稿小窓のタイトルが「新しいあふぅ」、本文欄のプレースホルダが「もう時間がないんです！」である' do
      open_composer
      within('form[role="dialog"]') do
        expect(page).to have_css('header h2', text: '新しいあふぅ')
        expect(page).to have_field(placeholder: 'もう時間がないんです！')
      end
    end

    def open_visibility_menu
      find('form[role="dialog"] button[aria-haspopup="menu"]', text: '公開資料').click
    end

    it '公開範囲メニューの見出しが「公開範囲」、選択肢が「公開資料」「私的資料」「楽屋には発言しない」である' do
      open_composer
      open_visibility_menu

      expect(page).to have_css('[role="group"]', text: '公開範囲')
      expect(page).to have_css('[role="menuitemradio"]', text: '公開資料')
      expect(page).to have_css('[role="menuitemradio"]', text: '私的資料')
      expect(page).to have_css('[role="menuitemcheckbox"]', text: '楽屋には発言しない')
    end

    it '検索結果に出さないようにすると、公開範囲のボタンが「社内資料」になる' do
      open_composer
      open_visibility_menu
      find('[role="menuitemcheckbox"]', text: '楽屋には発言しない').click
      send_keys :escape

      expect(page).to have_css('form[role="dialog"] button[aria-haspopup="menu"]', text: '社内資料')
    end

    # ja-IM で言い換えていない文言は、アプリと同じく ja、en の順に引き継がれる
    def ui_text(key)
      %w(ja-IM ja en).each do |locale|
        text = JSON.parse(Rails.root.join('app', 'javascript', 'mastodon', 'locales', "#{locale}.json").read)[key]
        return text if text
      end
    end

    it '閲覧注意のトグルが「早苗さんに見つからないようにする」、入力欄のラベルが「ζ\'ヮ\')ζ＜まえせつ」である' do
      open_composer
      find('form[role="dialog"] button[aria-haspopup="menu"]', text: ui_text('compose.settings')).click
      find('[role="menuitemcheckbox"]', text: '早苗さんに見つからないようにする').click

      expect(page).to have_css('form[role="dialog"] label', exact_text: "ζ'ヮ')ζ＜まえせつ")
    end

    it '返信の投稿小窓のタイトルが「Re:あふぅ」である'

    it 'メッセージに切り替えると、タイトルが「新しい機密資料」、ヒントが「指定した同僚だけに公開。暗号化はされません」、送信ボタンが「あふぅ」になる'

    it 'アカウントカードの「⋯」メニューに「理由あってブロック！」「だまっとけ☆リスト」がある'
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'imastodon カラーテーマ', :js, type: :system do
  include ProfileStories
  include ImastodonSystemHelpers

  def use_theme(theme, scheme, contrast: 'auto')
    login_and_visit_spa
    bob.settings['theme'] = theme
    bob.settings['web.color_scheme'] = scheme
    bob.settings['web.contrast'] = contrast
    bob.save!
    visit '/home'
    wait_for_react
  end

  # 色の書式（rgb() や color()、color-mix()）に左右されないよう、canvas に塗って RGBA を読む
  def rgba_of(css_color)
    page.evaluate_script(<<~JS, css_color)
      ((color) => {
        const ctx = document.createElement('canvas').getContext('2d');
        ctx.fillStyle = color;
        ctx.fillRect(0, 0, 1, 1);
        return Array.from(ctx.getImageData(0, 0, 1, 1).data);
      })(arguments[0])
    JS
  end

  # トークンは var() を含むので、要素に塗ってから計算済みの色を読む
  def token_color(token)
    page.evaluate_script(<<~JS, token)
      ((token) => {
        const probe = document.createElement('div');
        probe.style.backgroundColor = `var(${token})`;
        document.body.append(probe);
        const color = getComputedStyle(probe).backgroundColor;
        probe.remove();
        return color;
      })(arguments[0])
    JS
  end

  # カラムの外側はページ全体の背景（html 要素）が見えている
  def desktop_background
    page.evaluate_script('getComputedStyle(document.documentElement).backgroundColor')
  end

  def select_background
    find('select', match: :first).evaluate_script('getComputedStyle(this).backgroundColor')
  end

  def hue(css_color)
    r, g, b = rgba_of(css_color).first(3).map { |v| v / 255.0 }
    max, min = [r, g, b].minmax.reverse
    return 0.0 if max == min

    h = case max
        when r then (g - b) / (max - min)
        when g then 2 + ((b - r) / (max - min))
        else 4 + ((r - g) / (max - min))
        end
    (h * 60) % 360
  end

  def hue_distance(color1, color2)
    d = (hue(color1) - hue(color2)).abs
    [d, 360 - d].min
  end

  context 'シンデレラをダークで使う場合' do
    it 'カラムの外側の背景がテーマと同じ色相になる' do
      use_theme('cinderella', 'dark')

      expect(hue_distance(desktop_background, token_color('--color-bg-primary'))).to be < 15
    end

    it 'セレクトボックスの背景が不透明で、選択肢の一覧が透けない' do
      use_theme('cinderella', 'dark')
      visit '/settings/preferences/appearance'

      # 選択肢の一覧は OS が描くので、半透明の背景は白地に透けて白文字が読めなくなる
      expect(rgba_of(select_background).last).to eq 255
    end

    it '二次テキストが背景に透けない' do
      use_theme('cinderella', 'dark')

      # upstream は本文の色を半透明にして二次テキストを作る。中間の明るさの背景だと透けてコントラストが落ちる
      expect(rgba_of(token_color('--color-text-secondary')).last).to eq 255
      expect(rgba_of(token_color('--color-text-tertiary')).last).to eq 255
    end
  end

  context 'シンデレラをライトで使う場合' do
    it 'カラムの外側の背景がテーマと同じ色相になる' do
      use_theme('cinderella', 'light')

      expect(hue_distance(desktop_background, token_color('--color-bg-primary'))).to be < 15
    end

    it 'セレクトボックスの背景が不透明で、選択肢の一覧が透けない'
  end

  context 'ハイコントラストを有効にした場合' do
    it 'ボタンの色がテーマの色相のまま変わらない'
  end
end

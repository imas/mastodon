# frozen_string_literal: true

module AccountsHelper
  def display_name(account, **options)
    str = account.display_name.presence || account.username

    if options[:custom_emojify]
      prerender_custom_emojis(h(str), account.emojis)
    else
      str
    end
  end

  def acct(account)
    if account.local?
      "@#{account.acct}@#{site_hostname}"
    else
      "@#{account.pretty_acct}"
    end
  end

  def account_formatted_stat(value)
    number_to_human(value, precision: 3, strip_insignificant_zeros: true)
  end

  def account_description(account)
    prepend_str = [
      [
        account_formatted_stat(account.statuses_count),
        I18n.t('accounts.posts', count: account.statuses_count),
      ].join(' '),

      [
        account_formatted_stat(account.following_count),
        I18n.t('accounts.following', count: account.following_count),
      ].join(' '),

      [
        account_formatted_stat(account.followers_count),
        I18n.t('accounts.followers', count: account.followers_count),
      ].join(' '),
    ].join(', ')

    [prepend_str, account.note].join(' · ')
  end

  def svg_logo
    content_tag(:svg, tag.use('xlink:href' => '#mastodon-svg-logo'), 'viewBox' => '0 0 216.4144 232.00976')
  end

  def svg_logo_full
    # svgタグ埋め込みだと色が反映できないので
    image_pack_tag 'logo_full_imastodon.svg', class: 'logo', alt: 'iMastodon'
  end
end

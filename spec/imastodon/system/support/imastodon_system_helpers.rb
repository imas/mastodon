# frozen_string_literal: true

module ImastodonSystemHelpers
  def ignore_streaming_errors
    ignore_js_error(/ERR_CONNECTION_REFUSED/)
  end

  def ignore_react_warnings
    ignore_js_error(/uses the legacy childContextTypes API/)
  end

  def login_and_visit_spa(path = '/')
    @finished_onboarding = true
    ignore_streaming_errors
    ignore_react_warnings
    as_a_logged_in_user
    visit path
    wait_for_react
  end

  def enable_advanced_ui
    visit '/settings/preferences/appearance'
    check 'user_setting_advanced_layout'
    click_button I18n.t('generic.save_changes')
  end

  def disable_advanced_ui
    visit '/settings/preferences/appearance'
    uncheck 'user_setting_advanced_layout'
    click_button I18n.t('generic.save_changes')
  end

  def change_user_locale(locale)
    visit '/settings/preferences'
    select locale, from: 'user_locale'
    click_button I18n.t('generic.save_changes')
  end

  def wait_for_react
    expect(page).to have_css('.app-holder')
  end

  def api_token
    page.evaluate_script(<<~JS)
      JSON.parse(document.getElementById('initial-state').textContent).meta.access_token
    JS
  end
end

# frozen_string_literal: true

module ImastodonSystemHelpers
  def ignore_streaming_errors
    ignore_js_error(/ERR_CONNECTION_REFUSED/)
  end

  def ignore_react_warnings
    ignore_js_error(/uses the legacy childContextTypes API/)
    ignore_js_error(/uses the legacy contextTypes API/)
    ignore_js_error(/findDOMNode is deprecated/)
    ignore_js_error(/componentWillMount has been renamed/)
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
    find('input[type="checkbox"][id*="advanced_layout"]').check
    first('button[type="submit"]').click
  end

  def disable_advanced_ui
    visit '/settings/preferences/appearance'
    find('input[type="checkbox"][id*="advanced_layout"]').uncheck
    first('button[type="submit"]').click
  end

  def change_user_locale(locale)
    visit '/settings/preferences'
    find_by_id('user_locale').find("option[value='#{locale}']").select_option
    first('button[type="submit"]').click
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

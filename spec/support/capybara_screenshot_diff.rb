# frozen_string_literal: true

require 'capybara-screenshot-diff'

Capybara::ScreenshotDiff.configure do |config|
  config.save_path = Rails.root.join('doc', 'screenshots')
end

RSpec.configure do |config|
  config.include Capybara::ScreenshotDiff::DSL, type: :system
end

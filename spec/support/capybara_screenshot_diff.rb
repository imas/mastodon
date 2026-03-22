# frozen_string_literal: true

require 'capybara/screenshot/diff'

Capybara::Screenshot.save_path = Rails.root.join('doc', 'screenshots').to_s

RSpec.configure do |config|
  config.include Capybara::Screenshot::Diff, type: :system
end

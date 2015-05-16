if ENV.fetch("COVERAGE", false)
  require "simplecov"
  SimpleCov.start "rails"
end

ENV["RAILS_ENV"] ||= "test"
require "spec_helper"
require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"
require "shoulda/matchers"

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |file| require file }

ActiveRecord::Migration.maintain_test_schema!

Capybara.javascript_driver = :webkit

RSpec.configure do |config|
  config.include Features, type: :feature
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
end

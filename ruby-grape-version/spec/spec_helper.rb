ENV["RACK_ENV"] = "test"
require "loader"
require_relative "database_context"

require "simplecov"

SimpleCov.coverage_dir("coverage/backend")
SimpleCov.minimum_coverage 95
SimpleCov.start do
  enable_coverage :branch
end

RSpec.configure do |config|
  ENV["DATABASE_URL"] = "#{ENV['DATABASE_URL']}_test"
  database = Database.fresh_database

  config.before(:all) { @database = database }

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
end

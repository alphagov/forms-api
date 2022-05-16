ENV["RACK_ENV"] = "test"
require "loader"
require "pry"

RSpec.configure do |config|
  database = Database.fresh_database(ENV["TEST_DATABASE_URL"], ENV["TEST_DATABASE_NAME"])

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

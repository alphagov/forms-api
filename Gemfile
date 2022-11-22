source "https://rubygems.org"

ruby File.read(".ruby-version").chomp

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem "dotenv", "~> 2.8.1"
gem "pg", "~> 1.4.5"
gem "puma", "~> 5.6"
gem "sentry-ruby", "~> 5.6.0"
gem "sequel", "~> 5.62"
gem "zeitwerk", "~> 2.6"

group :development, :test do
  gem "pry"
end

group :development do
  gem "guard"
  gem "guard-rack"
  gem "rack-test"
  gem "rubocop"
end

group :test do
  gem "guard-rspec"
  gem "rspec"
  # Code coverage reporter
  gem "simplecov", "~> 0.21.2", require: false
end

gem "grape", "~> 1.6"

gem "grape-swagger", "~> 1.4"

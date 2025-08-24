source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: ".ruby-version"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.2"

gem "config"

# Auditing model changes and logging versions
gem "paper_trail"

# Add state machine for forms
gem "aasm", "~> 5.5"
# Used by AASM to autocommit state changes when even method is used with bang eg. make_live!
gem "after_commit_everywhere", "~> 1.6"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.6"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 6.6"

# Used for sorting/ordering of pages object
gem "acts_as_list"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

gem "tzinfo"
gem "tzinfo-data"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem "rack-cors"

# Our own custom markdown renderer
gem "govuk-forms-markdown", github: "alphagov/govuk-forms-markdown", tag: "0.6.0"

# For structured logging
gem "lograge"

gem "sentry-rails"
gem "sentry-ruby"

# Use validate_url so we don't have to write custom URL validation
gem "validate_url"

# For pausing pipelines
gem "aws-sdk-codepipeline", "~> 1.105"

# For pagination in the API
gem "kaminari"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"

  gem "factory_bot_rails"

  gem "faker"

  gem "rubocop-govuk", require: false

  gem "rspec-rails"

  # Security audit our Gemfile.lock file for any vulnerable dependencies
  gem "bundler-audit"

  # A static analysis security vulnerability scanner for Ruby on Rails applications
  gem "brakeman"
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Code coverage reporter
  gem "simplecov", require: false
end

gem "reverse_markdown", "~> 3.0"

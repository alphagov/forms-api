source "https://rubygems.org"

ruby File.read(".ruby-version").chomp

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem "puma", "~> 5.0"
gem "sinatra", "~> 2.2.0"
gem "zeitwerk", "~> 2.5"
gem 'sequel', '~> 5.55'
gem 'pg', '~> 1.3.5'

group :development do
  gem "rubocop"
end

group :test do
  gem "rspec"
end

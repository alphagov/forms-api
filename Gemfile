source "https://rubygems.org"

ruby File.read(".ruby-version").chomp

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem "puma", "~> 5.6.4"
gem "nokogiri", "~> 1.13.4"
gem "sinatra", "~> 2.2.0"
gem "zeitwerk", "~> 2.5"

group :development do
  gem "rubocop"
end

group :test do
  gem "rspec"
end

gem "rubocop-rails", "~> 2.14"
gem "bundler-audit", "~> 0.9.0"
gem "brakeman", "~> 5.2"

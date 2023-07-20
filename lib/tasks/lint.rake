desc "Lint with rubocop"
task lint: :environment do
  sh "bundle exec rubocop"
end

desc "Test with rspec"
task test: :environment do
  sh "bundle exec rspec"
end

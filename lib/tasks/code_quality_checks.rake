desc "Lint with rubocop"
task lint_rubocop: :environment do
  sh "bundle exec rubocop -A"
end

desc "Test with rspec"
task test_rspec: :environment do
  sh "bundle exec rspec"
end

desc "Run code quality checks"
multitask run_code_quality_checks: %i[lint_rubocop test_rspec]

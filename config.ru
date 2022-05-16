require './lib/loader'

unless ENV['SENTRY_DSN'].nil?
  require 'sentry-ruby'

  Sentry.init do |config|
    config.dsn = ENV['SENTRY_DSN']
    config.breadcrumbs_logger = [:sentry_logger, :http_logger]
    config.traces_sample_rate = 0.5
  end

  use Sentry::Rack::CaptureExceptions
end

$stdout.sync = true

Database.use do |db|
  migrator = Migrator.new
  migrator.migrate(db)
end
run Server

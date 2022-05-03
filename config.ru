RACK_ENV = ENV['RACK_ENV'] ||= 'development' unless defined?(RACK_ENV)
require 'dotenv'
require './lib/loader'

Dotenv.load(".env.#{RACK_ENV}")

unless ENV['SENTRY_DSN'].nil?
  require 'sentry'

  Sentry.init do |config|
    config.dsn = ENV['SENTRY_DSN']

    config.breadcrumbs_logger = [:sentry_logger, :http_logger]

    # To activate performance monitoring, set one of these options.
    # We recommend adjusting the value in production:
    config.traces_sample_rate = 0.5
    # or
    config.traces_sampler = lambda do |context|
      0.5
    end
  end
end

$stdout.sync = true

run Server

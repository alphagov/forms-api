if Settings.sentry.dsn.present?
  Sentry.init do |config|
    config.dsn = Settings.sentry.dsn
    config.breadcrumbs_logger = %i[active_support_logger http_logger]
    config.debug = true
    config.traces_sample_rate = 0.0
    config.environment = Settings.sentry.environment || "local"
  end
end

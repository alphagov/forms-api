require "./app/lib/json_log_formatter"

unless Rails.env.development?
  Rails.application.configure do
    #### lOGGING #####
    # Include generic and useful information about system operation, but avoid logging too much
    # information to avoid inadvertent exposure of personally identifiable information (PII).
    config.log_level = :info

    # Use JSON log formatter for better support in Splunk. To use conventional
    # logging use the Logger::Formatter.new.
    config.log_formatter = JsonLogFormatter.new

    if ENV["RAILS_LOG_TO_STDOUT"].present?
      config.logger = ActiveSupport::Logger.new($stdout)
      config.logger.formatter = config.log_formatter
    end

    # Lograge is used to format the standard HTTP request logging
    config.lograge.enabled = true
    config.lograge.formatter = Lograge::Formatters::Json.new

    config.lograge.custom_options = lambda do |event|
      {}.tap do |h|
        h[:host] = event.payload[:host]
        h[:request_id] = event.payload[:request_id]
        h[:requested_by] = event.payload[:requested_by] if event.payload[:requested_by]
        h[:form_id] = event.payload[:form_id] if event.payload[:form_id]
        h[:page_id] = event.payload[:page_id] if event.payload[:page_id]
        h[:params] = event.payload[:params].except(:controller, :action)
        h[:exception] = event.payload[:exception] if event.payload[:exception]
      end
    end
  end
end

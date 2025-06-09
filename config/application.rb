require_relative "boot"
require_relative "../app/lib/json_log_formatter"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FormsApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    I18n.available_locales = %i[en cy]

    #### lOGGING #####
    # Include generic and useful information about system operation, but avoid logging too much
    # information to avoid inadvertent exposure of personally identifiable information (PII).
    config.log_level = :info

    # Use JSON log formatter for better support in Splunk. To use conventional
    # logging use the Logger::Formatter.new.
    config.log_formatter = JsonLogFormatter.new

    # Lograge is used to format the standard HTTP request logging
    config.lograge.enabled = true
    config.lograge.formatter = Lograge::Formatters::Json.new

    config.lograge.custom_options = lambda do |event|
      {}.tap do |h|
        h[:request_host] = event.payload[:request_host]
        h[:request_id] = event.payload[:request_id]
        h[:requested_by] = event.payload[:requested_by] if event.payload[:requested_by]
        h[:form_id] = event.payload[:form_id] if event.payload[:form_id]
        h[:page_id] = event.payload[:page_id] if event.payload[:page_id]
        h[:params] = event.payload[:params].except(:controller, :action)
        h[:exception] = event.payload[:exception] if event.payload[:exception]
        h[:trace_id] = event.payload[:trace_id] if event.payload[:trace_id]
      end
    end

    # Prevent ActiveRecord::PreparedStatementCacheExpired errors when adding columns
    config.active_record.enumerate_columns_in_select_statements = true
  end
end

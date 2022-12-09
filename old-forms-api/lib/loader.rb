RACK_ENV = ENV["RACK_ENV"] ||= "development" unless defined?(RACK_ENV)

require "dotenv"
require "zeitwerk"
require_relative "server"
require_relative "../old-forms-api/db/database"
require_relative "../old-forms-api/db/migrator"

Dotenv.load(".env", ".env.#{RACK_ENV}")

loader = Zeitwerk::Loader.new
loader.push_dir(__dir__)
loader.setup

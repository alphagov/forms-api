require "zeitwerk"
require_relative "server"
require_relative "../db/database"
require_relative "../db/migrator"

loader = Zeitwerk::Loader.new
loader.push_dir(__dir__)
loader.setup

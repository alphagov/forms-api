require "dotenv/load"
require "zeitwerk"
require_relative "server"
require_relative "../db/database"

loader = Zeitwerk::Loader.new
loader.push_dir(__dir__)
loader.setup

require "zeitwerk"
require_relative "server"

loader = Zeitwerk::Loader.new
loader.push_dir(__dir__)
loader.setup

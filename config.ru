RACK_ENV = ENV['RACK_ENV'] ||= 'development' unless defined?(RACK_ENV)
require 'dotenv'
require './lib/loader'

Dotenv.load(".env.#{RACK_ENV}")

$stdout.sync = true

run Server

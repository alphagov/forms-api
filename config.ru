RACK_ENV = ENV['RACK_ENV'] ||= 'development' unless defined?(RACK_ENV)
require './lib/loader'

$stdout.sync = true

run Server

RACK_ENV = ENV['RACK_ENV'] ||= 'development' unless defined?(RACK_ENV)
require './lib/server'

$stdout.sync = true

run Server

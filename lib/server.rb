require 'sinatra'

class Server < Sinatra::Base
  get '/' do
    "GOV.UK Forms - API"
  end
end


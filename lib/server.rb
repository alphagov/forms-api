require "sinatra"

class Server < Sinatra::Base
  get "/" do
    Services::Example.new.execute
  end
end

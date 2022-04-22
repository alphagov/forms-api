require "sinatra"

class Server < Sinatra::Base
  get "/" do
    repo = Repositories::ExampleRepository.new
    res = repo.test_query

    Services::Example.new.execute(res[:result])
  end
end

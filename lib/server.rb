require "grape"
require 'grape-swagger'

class Server < Grape::API
  version 'v1', using: :path, vendor: 'forms'
  format :json
  prefix :api

  resource :forms do
    desc 'Returns all forms.'
    params do
      requires :result, type: Integer, desc: 'Result ID.'
    end
    route_param :result do
      get do
        Services::Example.new.execute(params[:result])
      end
    end

  end


  add_swagger_documentation hide_documentation_path: true,
                            api_version: 'v1',
                            info: {
                              title: 'GOV.UK Forms API',
                              description: 'Core Forms management API'
                            }
end

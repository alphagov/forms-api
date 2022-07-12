require "rack/test"

describe Server::Server do
  include Rack::Test::Methods

  def app
    Server::Server
  end

  context "GET /api/v1/forms" do
    it "returns a status code 401 when no authentication supplied" do
      get "/api/v1/forms"
      expect(last_response.status).to eq(401)
    end

    it "returns a status code 401 when incorrect API key supplied" do
      header "X-Api-Token", "an-incorrect-api-token"
      get "/api/v1/forms"
      expect(last_response.status).to eq(401)
    end

    it "returns a status code 200 when correct API key supplied" do
      header "X-Api-Token", ENV["API_KEY"]
      get "/api/v1/forms"
      expect(last_response.status).to eq(200)
    end
  end
end

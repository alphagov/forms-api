require "rack/test"

describe Server::Server do
  include Rack::Test::Methods

  def app
    Server::Server
  end

  context "when API_KEY set in ENV" do
    before do
      stub_const("ENV", ENV.to_hash.merge("API_KEY" => "an-api-key"))
    end

    it "returns a status code 401 when no authentication supplied" do
      get "/api/v1/forms", { org: "gds" }
      expect(last_response.status).to eq(401)
    end

    it "returns a status code 401 when incorrect API key supplied" do
      header "X-Api-Token", "an-incorrect-api-token"
      get "/api/v1/forms", { org: "gds" }
      expect(last_response.status).to eq(401)
    end

    it "returns a status code 200 when correct API key supplied" do
      header "X-Api-Token", ENV["API_KEY"]
      get "/api/v1/forms", { org: "gds" }
      expect(last_response.status).to eq(200)
    end

    it "returns a status code 200 for public endpoint when correct API key supplied" do
      get "/ping", "PONG"
      expect(last_response.status).to eq(200)
    end
  end

  context "when no API_KEY set in ENV" do
    before do
      stub_const("ENV", ENV.to_hash.merge("API_KEY" => nil))
    end

    it "returns a status code 401 when supplied with incorrect api key" do
      header "X-Api-Token", "an-api-key"
      get "/api/v1/forms", { org: "gds" }
      expect(last_response.status).to eq(401)
    end

    it "returns a status code 401 when supplied with no api key" do
      get "/api/v1/forms", { org: "gds" }
      expect(last_response.status).to eq(401)
    end

    it "returns a status code 200 for public endpoint when correct API key supplied" do
      get "/ping", "PONG"
      expect(last_response.status).to eq(200)
    end
  end
end

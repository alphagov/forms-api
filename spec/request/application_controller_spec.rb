require "rails_helper"

describe ApplicationController, type: :request do
  describe "#authentication" do
    let(:token) { Settings.forms_api.authentication_key }
    let(:req_headers) do
      {
        "X-API-Token" => token,
        "Accept" => "application/json",
      }
    end

    context "when valid header and token passed" do
      it "returns 200" do
        Settings.forms_api.authentication_key = 123_456
        get forms_path, params: { org: "gds" }, headers: req_headers
        expect(response.status).to eq(200)
      end
    end

    context "when token header key/value is missing from request" do
      let(:req_headers) do
        {
          "Accept" => "application/json",
        }
      end

      it "returns 401" do
        get forms_path, params: { org: "gds" }, headers: req_headers
        expect(response.status).to eq(401)
      end
    end

    context "when valid header and incorrect token passed" do
      let(:token) { "incorrect-auth-key" }

      it "returns 200" do
        Settings.forms_api.authentication_key = 123_456
        get forms_path, params: { org: "gds" }, headers: req_headers
        expect(response.status).to eq(401)
      end
    end
  end
end

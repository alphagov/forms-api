require "rails_helper"

describe ApplicationController, type: :request do
  describe "#authentication" do
    let(:token) { Settings.forms_api.authentication_key }
    let(:json_body) { JSON.parse(response.body, symbolize_names: true) }
    let(:req_headers) do
      {
        "X-API-Token" => token,
        "Accept" => "application/json",
      }
    end

    context "when authentication is turned off" do
      before do
        Settings.forms_api.enabled_auth = false
      end

      it "returns 200" do
        get forms_path, params: { org: "gds" }, headers: req_headers
        expect(response.status).to eq(200)
      end
    end

    context "when valid header and token passed" do
      it "returns 200" do
        Settings.forms_api.enabled_auth = true
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
        Settings.forms_api.enabled_auth = true
        Settings.forms_api.authentication_key = 123_456
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

    context "when passing in an authorization token" do
      let(:req_headers) do
        {
          "Authorization" => "Token #{token}",
          "Accept" => "application/json",
        }
      end
      let(:access_token) { AccessToken.create!(owner: "test-owner") }
      let(:token) { access_token.users_token }

      before do
        Settings.forms_api.enabled_auth = true
        Settings.forms_api.authentication_key = 1234
      end

      it "returns 200" do
        token
        get forms_path, params: { org: "gds" }, headers: req_headers
        expect(response.status).to eq(200)
      end

      context "when token has been deactivated" do
        let(:access_token) { AccessToken.create!(owner: "test-owner", deactivated_at: Time.zone.now) }

        before do
          token
          get forms_path, params: { org: "gds" }, headers: req_headers
        end

        it "returns 401" do
          expect(response.status).to eq(401)
        end

        it "returns an error message" do
          expect(json_body[:status]).to eq("unauthorised")
        end
      end
    end
  end
end

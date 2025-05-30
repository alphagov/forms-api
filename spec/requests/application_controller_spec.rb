require "rails_helper"

describe ApplicationController, type: :request do
  context "when there is a application load balancer trace ID" do
    let(:payloads) { [] }
    let(:payload) { payloads.last }

    let!(:subscriber) do
      ActiveSupport::Notifications.subscribe("process_action.action_controller") do |_, _, _, _, payload|
        payloads << payload
      end
    end

    before do
      get forms_path, headers: { "HTTP_X_AMZN_TRACE_ID": "Root=1-63441c4a-abcdef012345678912345678" }
    end

    after do
      ActiveSupport::Notifications.unsubscribe(subscriber)
    end

    it "adds the trace ID to the instrumentation payload" do
      expect(payload).to include(trace_id: "Root=1-63441c4a-abcdef012345678912345678")
    end
  end

  describe "#authentication" do
    let(:token) { Settings.forms_api.auth_key }
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
        get forms_path, headers: req_headers
        expect(response.status).to eq(200)
      end
    end

    context "when valid header and token passed" do
      it "returns 200" do
        Settings.forms_api.auth_key = 123_456
        Settings.forms_api.enabled_auth = true
        get forms_path, headers: req_headers
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
        Settings.forms_api.auth_key = 123_456
        Settings.forms_api.enabled_auth = true
        get forms_path, headers: req_headers
        expect(response.status).to eq(401)
      end
    end

    context "when valid header and incorrect token passed" do
      let(:token) { "incorrect-auth-key" }

      it "returns 200" do
        Settings.forms_api.auth_key = 123_456
        get forms_path, headers: req_headers
        expect(response.status).to eq(401)
      end
    end

    context "when using x-api-token header with access token" do
      let(:req_headers) do
        {
          "X-Api-Token" => token.to_s,
          "Accept" => "application/json",
        }
      end
      let(:access_token) { AccessToken.new(owner: "test-owner") }
      let(:token) { access_token.generate_token }
      let(:time_now) { Time.zone.now }

      before do
        Settings.forms_api.auth_key = 1234
        Settings.forms_api.enabled_auth = true
        access_token
        token
        access_token.save!
        freeze_time do
          time_now
          get forms_path, headers: req_headers
        end
      end

      it "returns 200" do
        expect(response.status).to eq(200)
      end

      it "updates the tokens 'last_accessed_at' attribute" do
        expect(access_token.reload.last_accessed_at).to eq time_now
      end

      context "when token has been deactivated" do
        let(:access_token) { AccessToken.new(owner: "test-owner", deactivated_at: Time.zone.now) }

        before do
          access_token
          token
          access_token.save!
          get forms_path, headers: req_headers
        end

        it "returns 401" do
          expect(response.status).to eq(401)
        end

        it "returns an error message" do
          expect(json_body[:status]).to eq("unauthorised")
        end
      end
    end

    context "when passing in an authorization token" do
      let(:req_headers) do
        {
          "Authorization" => "Token #{token}",
          "Accept" => "application/json",
        }
      end
      let(:access_token) { AccessToken.new(owner: "test-owner") }
      let(:token) { access_token.generate_token }
      let(:time_now) { Time.zone.now }

      before do
        Settings.forms_api.auth_key = 1234
        Settings.forms_api.enabled_auth = true
        access_token
        token
        access_token.save!
        freeze_time do
          time_now
          get forms_path, headers: req_headers
        end
      end

      it "returns 200" do
        expect(response.status).to eq(200)
      end

      it "updates the tokens 'last_accessed_at' attribute" do
        expect(access_token.reload.last_accessed_at).to eq time_now
      end

      context "when token has been deactivated" do
        let(:access_token) { AccessToken.new(owner: "test-owner", deactivated_at: Time.zone.now) }

        before do
          access_token
          token
          access_token.save!
          get forms_path, headers: req_headers
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

  describe "#up" do
    it "returns http code 200" do
      get rails_health_check_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "logging" do
    let(:output) { StringIO.new }
    let(:logger) { ActiveSupport::Logger.new(output) }
    let(:trace_id) { "Root=1-63441c4a-abcdef012345678912345678" }
    let(:request_id) { "a-request-id" }

    before do
      # Intercept the request logs so we can do assertions on them
      allow(Lograge).to receive(:logger).and_return(logger)

      get forms_path, headers: {
        "HTTP_X_AMZN_TRACE_ID": trace_id,
        "X-Request-ID": request_id,
      }
    end

    it "includes the trace ID on log lines" do
      expect(log_lines[0]["trace_id"]).to eq(trace_id)
    end

    it "includes the request_id on log lines" do
      expect(log_lines[0]["request_id"]).to eq(request_id)
    end

    it "includes the request_host on log lines" do
      expect(log_lines[0]["request_host"]).to eq("www.example.com")
    end
  end

  def log_lines
    output.string.split("\n").map { |line| JSON.parse(line) }
  end
end

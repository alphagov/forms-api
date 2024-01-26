require "rails_helper"

describe HeartbeatController, type: :request do
  describe "GET /ping" do
    it "returns PONG" do
      get ping_path

      expect(response.body).to eq "PONG"
    end

    context "when api auth token is set" do
      before do
        Settings.forms_api.authentication_key = 123_456
      end

      it "returns PONG" do
        get ping_path

        expect(response.body).to eq "PONG"
      end
    end
  end
end

require "rails_helper"

describe Api::V1::AccessTokensController, type: :request do
  let(:json_body) { JSON.parse(response.body, symbolize_names: true) }

  describe "#index" do
    let(:list_of_access_tokens) { create_list :access_token, 3 }

    it "returns a list of access tokens (excluding the token" do
      list_of_access_tokens
      get access_tokens_path

      json_body.each do |token|
        expect(token.keys).to contain_exactly(
          :id,
          :owner,
          :deactivated_at,
          :description,
          :created_at,
          :updated_at,
          :last_accessed_at,
        )
      end
    end
  end

  describe "#create" do
    before do
      allow(AccessToken).to receive(:new).and_return(OpenStruct.new(save: true, generate_token: "test-token"))
      post access_tokens_path, params: { owner: "testing user" }, as: :json
    end

    it "returns a user token" do
      expect(response.body).to eq({ token: "test-token" }.to_json)
    end

    it "returns 201 if its saved" do
      expect(response.status).to eq(201)
    end

    it "returns json" do
      expect(response.headers["Content-Type"]).to eq("application/json")
    end

    context "when a description is given" do
      before do
        allow(AccessToken).to receive(:new).and_call_original
        post access_tokens_path, params: { owner: "testing user", description: "This is one key to rule them all." }, as: :json
      end

      it "returns 201 if its saved" do
        expect(response.status).to eq(201)
      end

      it "returns json" do
        expect(response.headers["Content-Type"]).to eq("application/json")
      end

      it "sets the description" do
        expect(AccessToken.last.description).to eq "This is one key to rule them all."
      end
    end
  end

  describe "#deactivate" do
    let(:access_token) { create :access_token }
    let(:time_now) { Time.zone.now }

    before do
      freeze_time do
        time_now
        put deactivate_access_token_path(access_token.id)
      end
    end

    it "makes a token as expired with a date/time" do
      expect(access_token.reload.deactivated_at).to eq time_now
    end

    it "returns 200" do
      expect(response.status).to eq(200)
    end

    it "returns a status message" do
      expect(json_body).to eq({ status: "`#{access_token.owner}` has been deactivated" })
    end

    context "when access token is not found" do
      it "return a 404" do
        put deactivate_access_token_path(9999)
        expect(response.status).to eq(404)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq(error: "not_found")
      end
    end
  end
end

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
          :created_at,
          :updated_at,
        )
      end
    end
  end

  describe "#create" do
    before do
      allow(AccessToken).to receive(:new).and_return(OpenStruct.new(save: true, users_token: "test-token"))
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
  end
end
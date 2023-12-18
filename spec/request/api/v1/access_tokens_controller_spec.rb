require "rails_helper"

describe Api::V1::AccessTokensController, type: :request do
  let(:json_body) { JSON.parse(response.body, symbolize_names: true) }
  let(:time_now) { Time.zone.now }

  describe "#index" do
    let(:list_of_access_tokens) { create_list :access_token, 3 }

    it "returns a list of access tokens (excluding the token" do
      list_of_access_tokens
      get access_tokens_path

      json_body.each do |token|
        expect(token.keys).to contain_exactly(
          :id,
          :owner,
          :permissions,
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
      token = build(:access_token, id: 1)
      allow(token).to receive(:generate_token).and_return("test-token")
      allow(AccessToken).to receive(:new).and_return(token)
      post access_tokens_path, params: { owner: "testing user" }, as: :json
    end

    it "returns a user token" do
      expect(response.parsed_body).to include({ "id" => 1, "token" => "test-token" })
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

    context "when specific permissions are requested" do
      before do
        allow(AccessToken).to receive(:new).and_call_original
        post access_tokens_path, params: { owner: "testing user", permissions: :all }, as: :json
      end

      it "returns 201 if its saved" do
        expect(response).to have_http_status(:created)
      end

      it "returns json" do
        expect(response.headers["Content-Type"]).to eq("application/json")
      end

      it "sets the description" do
        expect(AccessToken.last.permissions).to eq "all"
      end
    end

    context "when invalid permissions are requested" do
      before do
        allow(AccessToken).to receive(:new).and_call_original
        post access_tokens_path, params: { owner: "testing user", permissions: :foobar }, as: :json
      end

      it "returns an error code" do
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe "#deactivate" do
    let(:access_token) { create :access_token }

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
      expect(json_body).to include(status: "`#{access_token.owner}` has been deactivated")
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

  describe "#caller-identity" do
    let(:access_token) { build :access_token }

    let(:token) do
      user_token = access_token.generate_token
      access_token.save!
      user_token
    end

    it "returns the details for the token used" do
      Settings.forms_api.enabled_auth = true
      allow(AccessToken.active).to receive(:find_by_token_digest).and_return(access_token)

      get show_details_for_access_tokens_path, params: nil, headers: { "Authorization" => "Token #{token}" }
      access_token.reload

      expect(json_body).to match(
        id: access_token.id,
        token_digest: access_token.token_digest,
        owner: access_token.owner,
        permissions: access_token.permissions,
        description: nil,
        deactivated_at: nil,
        created_at: access_token.created_at.as_json,
        updated_at: access_token.updated_at.as_json,
        last_accessed_at: access_token.last_accessed_at.as_json,
      )
    end

    context "when authenticated is not enabled" do
      it "returns not found" do
        Settings.forms_api.enabled_auth = false
        get show_details_for_access_tokens_path
        expect(response.status).to eq(404)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq(error: "Not found - No token used.")
      end
    end
  end
end

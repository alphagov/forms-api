require "rails_helper"

RSpec.describe "access control using access tokens" do
  context "when auth is enabled" do
    before do
      allow(Settings.forms_api).to receive(:enabled_auth).and_return(true)
    end

    let(:access) do
      AccessToken.new(owner: :test)
    end

    let!(:token) do
      token = access.generate_token
      access.save!
      token
    end

    it "denies access to the API if the request does not include an access token" do
      get forms_path

      expect(response).to have_http_status(:unauthorized)
    end

    it "denies access to the API if the request includes an invalid access token" do
      get forms_path, headers: { Authorization: "Token foobar" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "allows access to the API if the request includes an active access token" do
      get forms_path, headers: { Authorization: "Token #{token}" }

      expect(response).to have_http_status(:ok)
    end

    it "allows access to the API if the request includes an active access token as a bearer token" do
      get forms_path, headers: { Authorization: "Bearer #{token}" }

      expect(response).to have_http_status(:ok)
    end

    it "denies access to the API if the request includes a deactiveated access token" do
      put deactivate_access_token_path(access.id), headers: { AUTHORIZATION: "Token #{token}" }

      get forms_path, headers: { Authorization: "Token #{token}" }

      expect(response).to have_http_status(:unauthorized)
    end

    context "when a user has a readonly token" do
      let(:access) do
        AccessToken.new(owner: :test, permissions: :readonly)
      end

      let(:headers) do
        { Authorization: "Token #{token}" }
      end

      it "allows access to the API for GET requests" do
        get(forms_path, headers:)

        expect(response).to have_http_status(:ok)
      end

      it "denies access to the API for POST requests" do
        post(forms_path, params: { form: { name: "test form" } }, headers:)

        expect(response).to have_http_status(:unauthorized)
        expect(Form.last).to be nil
      end

      it "denies access to the API for PUT requests" do
        form = create :form, id: 1, name: "test form"

        put(form_path(1), params: { form: { name: "edited test form" } }, headers:)

        expect(response).to have_http_status(:unauthorized)
        expect(form.name).to eq "test form"
      end

      it "denies access to the API for PATCH requests" do
        form = create :form, id: 1, name: "test form"

        patch(form_path(1), params: { form: { name: "edited test form" } }, headers:)

        expect(response).to have_http_status(:unauthorized)
        expect(form.name).to eq "test form"
      end

      it "does not allow creating other access tokens" do
        post(access_tokens_path, params: { owner: "test" }, headers:)

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end

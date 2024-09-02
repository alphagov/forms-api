require "rails_helper"

RSpec.describe "/forms", type: :request do
  # This should return the minimal set of attributes required to create a valid
  # Api::V2::Form. As you add validations to Api::V2::Form, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    { external_id: "foobar" }
  end

  # This should return the minimal set of values that should be in the headers
  # in order to pass any filters (e.g. authentication) defined in
  # Api::V2::FormsController, or in your router and rack
  # middleware. Be sure to keep this updated too.
  let(:valid_headers) do
    {}
  end

  describe "GET /index" do
    it "renders a successful response" do
      Api::V2::Form.create! valid_attributes
      get api_v2_forms_url, headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      form = Api::V2::Form.create! valid_attributes
      get api_v2_form_url(form), as: :json
      expect(response).to be_successful
    end
  end
end

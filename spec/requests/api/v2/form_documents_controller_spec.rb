require "rails_helper"

RSpec.describe "/forms/:form_id/:tag", type: :request do
  # This should return the minimal set of values that should be in the headers
  # in order to pass any filters (e.g. authentication) defined in
  # Api::V2::FormsController, or in your router and rack
  # middleware. Be sure to keep this updated too.
  let(:valid_headers) do
    {}
  end

  describe "GET /show" do
    context "when there is a v1 form with the given external id" do
      let(:form) { create :form }
      let(:form_id) { form.external_id }

      it "renders a successful response" do
        get api_v2_form_document_url(form_id:, tag: :draft), as: :json
        expect(response).to have_http_status :success
      end

      it "sends a v2 API form document" do
        get api_v2_form_document_url(form_id:, tag: :draft), as: :json
        expect(response.parsed_body).to include "steps"
      end
    end
  end
end

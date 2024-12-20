require "rails_helper"

RSpec.describe Api::V2::FormDocumentsController, type: :request do
  # This should return the minimal set of values that should be in the headers
  # in order to pass any filters (e.g. authentication) defined in
  # Api::V2::FormsController, or in your router and rack
  # middleware. Be sure to keep this updated too.
  let(:valid_headers) do
    {}
  end

  describe "GET /index" do
    describe "tag query parameter" do
      before do
        create_list :form_document, 3, tag: :live
        create_list :form_document, 4, tag: :draft
      end

      context "when there is no tag query parameter" do
        it "returns all form documents" do
          get api_v2_form_documents_url, as: :json
          expect(response.parsed_body.length).to eq 7
        end
      end

      context "when there is a tag query parameter" do
        it "returns live form documents" do
          get api_v2_form_documents_url(tag: :live), as: :json
          expect(response.parsed_body.length).to eq 3
        end
      end
    end

    describe "pagination" do
      before do
        create_list :form_document, 11
      end

      context "when per_page query parameter is not provided" do
        before do
          get api_v2_form_documents_url, as: :json
        end

        it "returns first 10 results" do
          expect(response.parsed_body.length).to eq 10
        end

        it "includes pagination-total header" do
          expect(response.headers["pagination-total"]).to eq "11"
        end

        it "includes pagination-offset header" do
          expect(response.headers["pagination-offset"]).to eq "0"
        end

        it "includes pagination-limit header" do
          expect(response.headers["pagination-limit"]).to eq "10"
        end
      end

      context "when per_page query parameter is provided" do
        before do
          get api_v2_form_documents_url(per_page: 5), as: :json
        end

        it "returns the number of results specified by query parameter" do
          expect(response.parsed_body.length).to eq 5
        end

        it "includes pagination-total header" do
          expect(response.headers["pagination-total"]).to eq "11"
        end

        it "includes pagination-offset header" do
          expect(response.headers["pagination-offset"]).to eq "0"
        end

        it "includes pagination-limit header" do
          expect(response.headers["pagination-limit"]).to eq "5"
        end
      end

      context "when page query parameter is provided" do
        before do
          get api_v2_form_documents_url(page: 2), as: :json
        end

        it "returns the specified page of results" do
          expect(response.parsed_body.length).to eq 1
        end

        it "includes pagination-total header" do
          expect(response.headers["pagination-total"]).to eq "11"
        end

        it "includes pagination-offset header" do
          expect(response.headers["pagination-offset"]).to eq "10"
        end

        it "includes pagination-limit header" do
          expect(response.headers["pagination-limit"]).to eq "10"
        end
      end
    end
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

require "rails_helper"

RSpec.describe Api::V1::ReportsController, type: :request do
  describe "GET /features" do
    let!(:form_with_repeatable_question) { create(:form, state: :live, pages: [repeatable_page]) }
    let(:repeatable_page) { build(:page, answer_type: "text", is_repeatable: true) }

    before do
      create :form, state: :live, payment_url: Faker::Internet.url(host: "gov.uk"), submission_type: "email_with_csv", pages: [
        (build :page, answer_type: "text"),
        (build :page, answer_type: "text"),
      ]

      create :form, state: :live, pages: [
        (build :page, answer_type: "name"),
        (build :page, answer_type: "organisation_name"),
        (build :page, answer_type: "phone_number"),
        (build :page, answer_type: "email"),
        (build :page, answer_type: "address"),
        (build :page, answer_type: "national_insurance_number"),
        (build :page, answer_type: "date"),
        (build :page, answer_type: "number"),
        (build :page, answer_type: "selection", routing_conditions: [(build :condition)]),
        (build :page, answer_type: "text"),
      ]

      get "/api/v1/reports/features"
    end

    it "returns the breakdown of form features used" do
      response_hash = JSON.parse(response.body, symbolize_names: true)

      expect(response_hash).to eq({
        total_live_forms: 3,
        live_forms_with_answer_type: {
          name: 1,
          organisation_name: 1,
          phone_number: 1,
          email: 1,
          address: 1,
          national_insurance_number: 1,
          date: 1,
          number: 1,
          selection: 1,
          text: 3,
        },
        live_pages_with_answer_type: {
          name: 1,
          organisation_name: 1,
          phone_number: 1,
          email: 1,
          address: 1,
          national_insurance_number: 1,
          date: 1,
          number: 1,
          selection: 1,
          text: 4,
        },
        live_forms_with_payment: 1,
        live_forms_with_routing: 1,
        live_forms_with_add_another_answer: 1,
        live_forms_with_csv_submission_enabled: 1,
        all_forms_with_add_another_answer: [{ form_id: form_with_repeatable_question.id, name: form_with_repeatable_question.name, repeatable_pages: [{ page_id: repeatable_page.id, question_text: repeatable_page.question_text }] }],
      })
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end
end

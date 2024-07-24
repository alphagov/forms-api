require "rails_helper"

RSpec.describe Api::V1::ReportsController, type: :request do
  describe "GET /features" do
    before do
      create :form, payment_url: Faker::Internet.url(host: "gov.uk"), pages: [
        (build :page, answer_type: "text"),
        (build :page, answer_type: "text"),
      ]

      create :form, pages: [
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
      expect(response.body).to eq({
        total_forms: 2,
        answer_types: {
          name: 1,
          organisation_name: 1,
          phone_number: 1,
          email: 1,
          address: 1,
          national_insurance_number: 1,
          date: 1,
          number: 1,
          selection: 1,
          text: 2,
        },
        payment: 1,
        routing: 1,
      }.to_json)
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end
end

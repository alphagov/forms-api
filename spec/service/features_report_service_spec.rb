require "rails_helper"

describe FeaturesReportService do
  let(:features_report_service) { described_class.new }

  let(:pages) do
    [
      (build :page, answer_type: "name"),
      (build :page, answer_type: "organisation_name"),
      (build :page, answer_type: "phone_number"),
      (build :page, answer_type: "email"),
      (build :page, answer_type: "address"),
      (build :page, answer_type: "national_insurance_number"),
      (build :page, answer_type: "date"),
      (build :page, answer_type: "number"),
      (build :page, answer_type: "selection"),
      (build :page, answer_type: "text"),
    ]
  end

  let(:payment_url) { nil }

  describe "#report" do
    before do
      create :form, pages:, payment_url:
    end

    it "includes the number of total forms in the report" do
      response = features_report_service.report

      expect(response[:total_forms]).to eq 1
    end

    it "includes the number of forms that use each answer type" do
      response = features_report_service.report

      expect(response[:answer_types][:name]).to eq 1
      expect(response[:answer_types][:organisation_name]).to eq 1
      expect(response[:answer_types][:phone_number]).to eq 1
      expect(response[:answer_types][:email]).to eq 1
      expect(response[:answer_types][:address]).to eq 1
      expect(response[:answer_types][:national_insurance_number]).to eq 1
      expect(response[:answer_types][:date]).to eq 1
      expect(response[:answer_types][:number]).to eq 1
      expect(response[:answer_types][:selection]).to eq 1
      expect(response[:answer_types][:text]).to eq 1
    end

    context "when a form has more than one instance of a single answer type" do
      let(:pages) do
        [
          (build :page, answer_type: "text"),
          (build :page, answer_type: "text"),
        ]
      end

      it "only counts the form once for each answer type" do
        response = features_report_service.report

        expect(response[:answer_types][:text]).to eq 1
      end
    end

    context "when a form has a payment url" do
      let(:payment_url) { Faker::Internet.url(host: "gov.uk") }

      it "counts the form in the payment part of the report" do
        response = features_report_service.report

        expect(response[:payment]).to eq 1
      end
    end

    context "when a form has a route" do
      let(:pages) do
        [
          (build :page, answer_type: "selection", routing_conditions: [(build :condition)]),
        ]
      end

      it "counts the form in the routing part of the report" do
        response = features_report_service.report

        expect(response[:routing]).to eq 1
      end
    end
  end
end

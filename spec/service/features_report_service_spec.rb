require "rails_helper"

describe FeaturesReportService do
  let(:features_report_service) { described_class.new }

  let(:state) { %i[live live_with_draft].sample }

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
      create :form, state:, pages:, payment_url:
    end

    context "when the form is live" do
      let(:state) { %i[live live_with_draft].sample }

      it "includes the number of total live forms in the report" do
        response = features_report_service.report

        expect(response[:total_live_forms]).to eq 1
      end

      it "includes the number of forms that use each answer type" do
        response = features_report_service.report

        expect(response[:live_forms_with_answer_type][:name]).to eq 1
        expect(response[:live_forms_with_answer_type][:organisation_name]).to eq 1
        expect(response[:live_forms_with_answer_type][:phone_number]).to eq 1
        expect(response[:live_forms_with_answer_type][:email]).to eq 1
        expect(response[:live_forms_with_answer_type][:address]).to eq 1
        expect(response[:live_forms_with_answer_type][:national_insurance_number]).to eq 1
        expect(response[:live_forms_with_answer_type][:date]).to eq 1
        expect(response[:live_forms_with_answer_type][:number]).to eq 1
        expect(response[:live_forms_with_answer_type][:selection]).to eq 1
        expect(response[:live_forms_with_answer_type][:text]).to eq 1
      end

      context "when a form has more than one instance of a single answer type" do
        let(:pages) do
          [
            (build :page, answer_type: "text"),
            (build :page, answer_type: "text"),
          ]
        end

        it "counts the form once" do
          response = features_report_service.report

          expect(response[:live_forms_with_answer_type][:text]).to eq 1
        end

        it "counts all instances of the page" do
          response = features_report_service.report

          expect(response[:live_pages_with_answer_type][:text]).to eq 2
        end
      end

      context "when a form has a payment url" do
        let(:payment_url) { Faker::Internet.url(host: "gov.uk") }

        context "when the form is not live" do
          let(:state) { %i[draft archived archived_with_draft].sample }

          it "does not count the form in the payment part of the report" do
            response = features_report_service.report

            expect(response[:live_forms_with_payment]).to eq 0
          end
        end

        it "counts the form in the payment part of the report" do
          response = features_report_service.report

          expect(response[:live_forms_with_payment]).to eq 1
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

          expect(response[:live_forms_with_routing]).to eq 1
        end
      end
    end
  end

  context "when the form is not live" do
    let(:state) { %i[draft archived archived_with_draft].sample }

    context "when the form has a route, a payment URL, and all answer types" do
      let(:payment_url) { Faker::Internet.url(host: "gov.uk") }

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
          (build :page, answer_type: "selection", routing_conditions: [(build :condition)]),
          (build :page, answer_type: "text"),
        ]
      end

      it "does not count the form in any of the report metrics" do
        response = features_report_service.report

        expect(response[:live_forms_with_answer_type]).to eq({})

        expect(response[:live_pages_with_answer_type]).to eq({})

        expect(response[:live_forms_with_payment]).to eq 0
        expect(response[:live_forms_with_routing]).to eq 0
      end
    end
  end
end

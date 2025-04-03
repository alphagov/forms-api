require "rails_helper"

describe Reports::FeatureUsageService do
  let(:features_report_service) { described_class.new }

  let!(:pages_with_all_answer_types) do
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
      (build :page, answer_type: "file"),
    ]
  end

  let!(:pages_with_repeated_answer_type) do
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
      (build :page, answer_type: "file"),
      (build :page, answer_type: "text"),
      (build :page, answer_type: "text"),
    ]
  end

  let!(:pages_with_a_route) do
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
      (build :page, answer_type: "file"),
    ]
  end

  let!(:pages_with_add_another_answer) do
    [
      (build :page, answer_type: "name", is_repeatable: true),
    ]
  end

  let(:form_1_pages) { pages_with_all_answer_types }
  let(:form_2_pages) { pages_with_all_answer_types }
  let(:form_3_pages) { pages_with_repeated_answer_type }
  let(:form_4_pages) { pages_with_all_answer_types }
  let(:form_5_pages) { pages_with_repeated_answer_type }
  let(:form_6_pages) { pages_with_with_add_another_answer }

  let(:payment_url) { nil }
  let(:submission_type) { "email" }

  describe "#report" do
    before do
      create(:form, state: "draft", pages: form_1_pages, payment_url:)
      create(:form, state: "archived", pages: form_2_pages, payment_url:)
      create(:form, state: "archived_with_draft", pages: form_3_pages, payment_url:)
    end

    context "when there are live forms" do
      before do
        create(:form, state: "live", pages: form_4_pages, payment_url:, submission_type:)
        create(:form, state: "live_with_draft", pages: form_5_pages, payment_url: nil)
      end

      it "includes the number of total live forms in the report" do
        response = features_report_service.report

        expect(response[:total_live_forms]).to eq 2
      end

      it "includes the number of live forms that use each answer type" do
        response = features_report_service.report

        expect(response[:live_forms_with_answer_type][:name]).to eq 2
        expect(response[:live_forms_with_answer_type][:organisation_name]).to eq 2
        expect(response[:live_forms_with_answer_type][:phone_number]).to eq 2
        expect(response[:live_forms_with_answer_type][:email]).to eq 2
        expect(response[:live_forms_with_answer_type][:address]).to eq 2
        expect(response[:live_forms_with_answer_type][:national_insurance_number]).to eq 2
        expect(response[:live_forms_with_answer_type][:date]).to eq 2
        expect(response[:live_forms_with_answer_type][:number]).to eq 2
        expect(response[:live_forms_with_answer_type][:selection]).to eq 2
        expect(response[:live_forms_with_answer_type][:text]).to eq 2
        expect(response[:live_forms_with_answer_type][:file]).to eq 2
      end

      it "includes the number of live pages that use each answer type" do
        response = features_report_service.report

        expect(response[:live_pages_with_answer_type][:name]).to eq 2
        expect(response[:live_pages_with_answer_type][:organisation_name]).to eq 2
        expect(response[:live_pages_with_answer_type][:phone_number]).to eq 2
        expect(response[:live_pages_with_answer_type][:email]).to eq 2
        expect(response[:live_pages_with_answer_type][:address]).to eq 2
        expect(response[:live_pages_with_answer_type][:national_insurance_number]).to eq 2
        expect(response[:live_pages_with_answer_type][:date]).to eq 2
        expect(response[:live_pages_with_answer_type][:number]).to eq 2
        expect(response[:live_pages_with_answer_type][:selection]).to eq 2
        expect(response[:live_forms_with_answer_type][:file]).to eq 2
        expect(response[:live_pages_with_answer_type][:text]).to eq 3
      end

      context "when a live form has a payment url" do
        let(:payment_url) { Faker::Internet.url(host: "gov.uk") }

        it "counts the form in the payment part of the report" do
          response = features_report_service.report

          expect(response[:live_forms_with_payment]).to eq 1
        end
      end

      context "when a live form has a route" do
        let(:form_5_pages) { pages_with_a_route }

        it "counts the form in the routing part of the report" do
          response = features_report_service.report

          expect(response[:live_forms_with_routing]).to eq 1
        end
      end

      context "when a live form uses the add another answer feature" do
        let(:form_5_pages) { pages_with_add_another_answer }

        it "counts the form in the add another answer part of the report" do
          response = features_report_service.report

          expect(response[:live_forms_with_add_another_answer]).to eq 1
        end
      end

      context "when a live form has CSV submission enabled" do
        let(:submission_type) { "email_with_csv" }

        it "counts the form in the CSV submission part of the report" do
          response = features_report_service.report

          expect(response[:live_forms_with_csv_submission_enabled]).to eq 1
        end
      end

      context "when a draft form uses the add another answer feature" do
        let!(:add_another_answer_form) { create(:form, state: "draft", pages: form_5_pages) }
        let(:form_5_pages) { pages_with_add_another_answer }

        it "obtains all forms in the add another answer report" do
          response = features_report_service.report

          expect(response[:all_forms_with_add_another_answer]).to eq([{ form_id: add_another_answer_form.id, name: add_another_answer_form.name, state: add_another_answer_form.state, repeatable_pages: [{ page_id: pages_with_add_another_answer.first.id, question_text: pages_with_add_another_answer.first.question_text }] }])
        end
      end
    end

    context "when there are no live forms" do
      it "has non-live forms in the database" do
        draft_forms_count = Form.where(state: "draft").count
        archived_forms_count = Form.where(state: "archived").count
        archived_with_draft_forms_count = Form.where(state: "archived_with_draft").count

        expect(draft_forms_count).to be > 0
        expect(archived_forms_count).to be > 0
        expect(archived_with_draft_forms_count).to be > 0
      end

      it "does not count the form in any of the report metrics" do
        response = features_report_service.report

        expect(response[:total_live_forms]).to eq 0

        expect(response[:live_forms_with_answer_type]).to eq({})
        expect(response[:live_pages_with_answer_type]).to eq({})

        expect(response[:live_forms_with_payment]).to eq 0
        expect(response[:live_forms_with_routing]).to eq 0
        expect(response[:live_forms_with_csv_submission_enabled]).to eq 0
      end
    end
  end

  describe "#add_another_answer_forms" do
    let!(:add_another_answer_draft_form) { create(:form, state: "draft", pages: draft_form_pages) }
    let(:draft_form_pages) { pages_with_add_another_answer }
    let!(:add_another_answer_live_form) { create(:form, state: "live", pages: live_form_pages) }
    let(:live_form_pages) do
      [
        (build :page, answer_type: "name", is_repeatable: true),
        (build :page, answer_type: "text", is_repeatable: true),
      ]
    end

    it "obtains all forms in the add another answer report" do
      report = features_report_service.add_another_answer_forms

      expect(report[:forms]).to contain_exactly({
        form_id: add_another_answer_draft_form.id,
        name: add_another_answer_draft_form.name,
        state: add_another_answer_draft_form.state,
        repeatable_pages: contain_exactly({ page_id: draft_form_pages.first.id, question_text: draft_form_pages.first.question_text }),
      }, {
        form_id: add_another_answer_live_form.id,
        name: add_another_answer_live_form.name,
        state: add_another_answer_live_form.state,
        repeatable_pages: contain_exactly(
          { page_id: live_form_pages.first.id, question_text: live_form_pages.first.question_text },
          { page_id: live_form_pages.second.id, question_text: live_form_pages.second.question_text },
        ),
      })
    end

    it "returns the count" do
      report = features_report_service.add_another_answer_forms
      expect(report[:count]).to eq 2
    end
  end
end

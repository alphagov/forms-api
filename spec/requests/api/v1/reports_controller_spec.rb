require "rails_helper"

RSpec.describe Api::V1::ReportsController, type: :request do
  describe "GET /add-another-answer-forms" do
    let!(:form_with_repeatable_question) { create(:form, state: :live, pages: [repeatable_page]) }
    let(:repeatable_page) { build(:page, answer_type: "text", is_repeatable: true) }

    before do
      create :form, state: :live, pages: [
        (build :page, answer_type: "text"),
        (build :page, answer_type: "text"),
      ]

      get "/api/v1/reports/add-another-answer-forms"
    end

    it "returns the forms with repeatable questions" do
      response_hash = JSON.parse(response.body, symbolize_names: true)

      expect(response_hash).to eq({
        count: 1,
        forms: [
          {
            form_id: form_with_repeatable_question.id,
            name: form_with_repeatable_question.name,
            state: form_with_repeatable_question.state,
            repeatable_pages: [
              { page_id: repeatable_page.id, question_text: repeatable_page.question_text },
            ],
          },
        ],
      })
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /selection-questions-summary" do
    before do
      form_1_pages = [
        build(:page, :selection_with_autocomplete, is_optional: false),
        build(:page, :selection_with_autocomplete, is_optional: true),
        build(:page, :selection_with_radios, is_optional: true),
        build(:page, :selection_with_checkboxes, is_optional: true),
      ]
      form_2_pages = [
        build(:page, :selection_with_autocomplete, is_optional: true),
        build(:page, :selection_with_radios, is_optional: false),
      ]
      create :form, id: 1, state: "live", pages: form_1_pages
      create :form, id: 2, state: "live_with_draft", pages: form_2_pages

      get "/api/v1/reports/selection-questions-summary"
    end

    it "returns statistics" do
      response_hash = JSON.parse(response.body, symbolize_names: true)
      expect(response_hash).to eq({
        autocomplete: {
          form_count: 2,
          question_count: 3,
          optional_question_count: 2,
        },
        radios: {
          form_count: 2,
          question_count: 2,
          optional_question_count: 1,
        },
        checkboxes: {
          form_count: 1,
          question_count: 1,
          optional_question_count: 1,
        },
      })
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /selection-questions-with-autocomplete" do
    let(:page) { build(:page, :selection_with_autocomplete, is_optional: "true") }

    before do
      create :form, state: "live", pages: [page]
      get "/api/v1/reports/selection-questions-with-autocomplete"
    end

    it "returns a list of selection questions" do
      response_hash = JSON.parse(response.body, symbolize_names: true)

      expect(response_hash).to eq({
        questions: [
          {
            form_id: page.form.id,
            form_name: page.form.name,
            question_text: page.question_text,
            is_optional: page.is_optional,
            selection_options_count: page.answer_settings["selection_options"].length,
          },
        ],
        count: 1,
      })
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /selection-questions-with-radios" do
    let(:page) { build(:page, :selection_with_radios, is_optional: "true") }

    before do
      create :form, state: "live", pages: [page]
      get "/api/v1/reports/selection-questions-with-radios"
    end

    it "returns a list of selection questions" do
      response_hash = JSON.parse(response.body, symbolize_names: true)

      expect(response_hash).to eq({
        questions: [
          {
            form_id: page.form.id,
            form_name: page.form.name,
            question_text: page.question_text,
            is_optional: page.is_optional,
            selection_options_count: page.answer_settings["selection_options"].length,
          },
        ],
        count: 1,
      })
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /selection-questions-with-checkboxes" do
    let(:page) { build(:page, :selection_with_checkboxes, is_optional: "true") }

    before do
      create :form, state: "live", pages: [page]
      get "/api/v1/reports/selection-questions-with-checkboxes"
    end

    it "returns a list of selection questions" do
      response_hash = JSON.parse(response.body, symbolize_names: true)

      expect(response_hash).to eq({
        questions: [
          {
            form_id: page.form.id,
            form_name: page.form.name,
            question_text: page.question_text,
            is_optional: page.is_optional,
            selection_options_count: page.answer_settings["selection_options"].length,
          },
        ],
        count: 1,
      })
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end
end

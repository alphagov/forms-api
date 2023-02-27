require "rails_helper"

describe Api::V1::PagesController, type: :request do
  let(:json_body) { JSON.parse(response.body, symbolize_names: true) }

  describe "#index" do
    it "when no pages exist for a form, returns 200 and an empty json array" do
      form = create :form
      get "/api/v1/forms/#{form.id}/pages", as: :json
      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq([])
    end

    it "when given a form, returns a json array of pages" do
      form = create :form, :with_pages
      get "/api/v1/forms/#{form.id}/pages", as: :json
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body.count).to eq(form.pages.count)
      form.pages.each_with_index do |p, i|
        expect(json_body[i]).to eq(JSON.parse(p.to_json).symbolize_keys)
      end
    end
  end

  describe "#create" do
    let(:form) { create :form }
    let(:new_page_params) do
      {
        form_id: form.id,
        question_text: "What is your first name?",
        hint_text: "Should be first/last name",
        answer_type: "text",
        is_optional: false,
        answer_settings: { "input_type" => "single_line" },
      }
    end
    let(:new_page) { form.pages.first }

    before do
      # fix the time here so we can test created_at and updated_at explicitly
      travel_to Time.zone.local(2023, 1, 1, 12, 0, 0) do
        post "/api/v1/forms/#{form.id}/pages", params: new_page_params, as: :json
      end
    end

    it "returns page id, status code 201 when new page created" do
      expect(response.status).to eq(201)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq({ id: new_page.id })
    end

    it "creates DB row with new_page_params, fresh id, form_id set and next_page: nil" do
      expect(new_page.as_json).to eq(new_page_params.merge(id: new_page[:id],
                                                           form_id: form[:id],
                                                           next_page: nil,
                                                           position: 1,
                                                           conditions: [],
                                                           created_at: "2023-01-01T12:00:00.000Z",
                                                           updated_at: "2023-01-01T12:00:00.000Z").as_json)
    end

    context "with params missing required keys" do
      let(:new_page_params) do
        { wrong: "" }
      end

      it "returns page id, status code 400 and an array of messages" do
        expect(response.status).to eq(400)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq(error: "param is missing or the value is empty: page")
      end

      it "does not create a new page row" do
        page_count = Page.where(form_id: form.id).count
        expect(page_count).to eq(0)
      end
    end

    context "with a form with question_section_completed = true" do
      let(:form) { create :form, question_section_completed: true }

      it "marks sets the form's question_section_completed as false" do
        expect(form.reload.question_section_completed).to be false
      end
    end
  end

  describe "#show" do
    let(:form) { create :form, :with_pages, pages_count: 2 }
    let(:page1) { form.pages.first }
    let(:page2) { form.pages[1] }

    let(:form_id) { form.id }
    let(:page_id) { page1.id }

    before do
      get "/api/v1/forms/#{form_id}/pages/#{page_id}", as: :json
    end

    context "when page exists" do
      it "returns page, status code 200" do
        expect(response.status).to eq(200)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq(JSON.parse(page1.to_json).symbolize_keys)
      end
    end

    context "when page does not exist" do
      let(:page_id) { 999 }

      it "returns status code 404" do
        expect(response.status).to eq(404)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq({ error: "not_found" })
      end
    end

    context "when form does not exist" do
      let(:form_id) { 999 }

      it "returns a 404 with a json error" do
        expect(response.status).to eq(404)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq({ error: "not_found" })
      end
    end
  end

  describe "#update" do
    let(:form) { create :form, :with_pages, pages_count: 2 }
    let(:page1) { form.pages.first }
    let(:page2) { form.pages[1] }

    let(:answer_type) { "national_insurance_number" }
    let(:answer_settings) { nil }
    let(:params) { { question_text: "updated page title", answer_type:, answer_settings: } }

    before do
      put "/api/v1/forms/#{form.id}/pages/#{page1.id}", params:, as: :json
    end

    it "returns correct response" do
      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq({ success: true })
      expect(page1.reload.question_text).to eq("updated page title")
      expect(form.reload.question_section_completed).to be false
    end

    it "fields not in the params are cleared" do
      expect(page1.hint_text).to be_nil
    end

    [
      ["selection",
       {
         only_one_option: "true",
         selection_options: [{ "name" => "one" }, { "name" => "tw0" }],
       }],
      ["text",
       {
         input_type: "single_line",
       }],
      ["number", nil],
    ].each do |type, settings|
      context "with nested answer_settings" do
        let(:answer_type) { type }
        let(:answer_settings) { settings }

        it "returns correct response" do
          expect(response.status).to eq(200)
          expect(response.headers["Content-Type"]).to eq("application/json")
          expect(json_body).to eq({ success: true })
          page1.reload
          expect(page1.answer_settings&.symbolize_keys).to eq(settings)
        end
      end
    end

    context "with nested answer_settings and input_type" do
      let(:answer_type) { "address" }
      let(:answer_settings) do
        {
          input_type: {
            uk_address: "true",
            international_address: "true",
          },
        }
      end

      it "returns correct response" do
        expect(response.status).to eq(200)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq({ success: true })
        page1.reload
        expect(page1.answer_settings&.deep_symbolize_keys).to eq(answer_settings)
      end
    end
  end

  describe "#destroy" do
    let(:form) { create :form, :with_pages, pages_count: 2 }
    let(:page1) { form.pages.first }
    let(:page2) { form.pages[1] }

    let(:form_id) { form.id }
    let(:page_id) { page1.id }

    before do
      delete "/api/v1/forms/#{form_id}/pages/#{page_id}", as: :json
    end

    context "with exisitng page" do
      it "removes page and returns correct response" do
        expect(response.status).to eq(200)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq({ success: true })
        expect(form.pages.count).to eq(1)
        expect(form.reload.question_section_completed).to be false
      end
    end

    context "with unknown form" do
      let(:form_id) { 999 }

      it "returns 404" do
        expect(response.status).to eq(404)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq({ error: "not_found" })
        expect(form.pages.count).to eq(2)
      end
    end

    context "with unknown page" do
      let(:page_id) { 999 }

      it "returns 404" do
        expect(response.status).to eq(404)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq({ error: "not_found" })
        expect(form.pages.count).to eq(2)
      end
    end
  end

  describe "#move_down" do
    let(:form_with_pages) { create :form, :with_pages }

    let(:page_to_move) { form_with_pages.pages.first }
    let(:first_page) { form_with_pages.pages.first }
    let(:second_page) { form_with_pages.pages.second }
    let(:third_page) { form_with_pages.pages.third }
    let(:fourth_page) { form_with_pages.pages.fourth }
    let(:last_page) { form_with_pages.pages.last }

    before do
      put "/api/v1/forms/#{form_with_pages.id}/pages/#{page_to_move.id}/down"
    end

    context "with valid page" do
      it "returns correct response" do
        expect(response.status).to eq(200)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq({ success: 1 })
      end

      it "changes order of pages returned" do
        get "/api/v1/forms/#{form_with_pages.id}/pages"
        expect(json_body.map { |p| p[:id] }).to eq([second_page.id, page_to_move.id, third_page.id, fourth_page.id, last_page.id])
      end
    end

    context "with page already at the end of the list" do
      let(:page_to_move) { last_page }

      it "returns correct response" do
        expect(response.status).to eq(200)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq({ success: 1 })
      end

      it "does not change order of pages" do
        get "/api/v1/forms/#{form_with_pages.id}/pages"
        expect(json_body.map { |p| p[:id] }).to eq([first_page.id, second_page.id, third_page.id, fourth_page.id, page_to_move.id])
      end
    end
  end

  describe "#move_up" do
    let(:form_with_pages) { create :form, :with_pages }

    let(:page_to_move) { second_page }
    let(:first_page) { form_with_pages.pages.first }
    let(:second_page) { form_with_pages.pages.second }
    let(:third_page) { form_with_pages.pages.third }
    let(:fourth_page) { form_with_pages.pages.fourth }
    let(:last_page) { form_with_pages.pages.last }

    before do
      put "/api/v1/forms/#{form_with_pages.id}/pages/#{page_to_move.id}/up"
    end

    context "with valid page" do
      it "returns correct response" do
        expect(response.status).to eq(200)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq({ success: 1 })
      end

      it "changes order of pages returned" do
        get "/api/v1/forms/#{form_with_pages.id}/pages"
        expect(json_body.map { |p| p[:id] }).to eq([page_to_move.id, first_page.id, third_page.id, fourth_page.id, last_page.id])
      end
    end

    context "with page already at the start of the list" do
      let(:page_to_move) { first_page }

      it "returns correct response" do
        expect(response.status).to eq(200)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq({ success: 1 })
      end

      it "does not change order of pages" do
        get "/api/v1/forms/#{form_with_pages.id}/pages"
        expect(json_body.map { |p| p[:id] }).to eq([page_to_move.id, second_page.id, third_page.id, fourth_page.id, last_page.id])
      end
    end
  end
end

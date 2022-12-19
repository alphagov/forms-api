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
        expect(json_body[i]).to eq(p.attributes.transform_keys(&:to_sym))
      end
    end
  end

  describe "#create" do
    let(:form) { create :form }
    let(:new_page_params) do
      {
        form_id: form.id,
        question_text: "What is your first name?",
        question_short_name: "",
        hint_text: "Should be first/last name",
        answer_type: "single_line",
        is_optional: false,
        answer_settings: nil,
      }
    end
    let(:new_page) { form.pages.first }

    before do
      post "/api/v1/forms/#{form.id}/pages", params: new_page_params, as: :json
    end

    it "returns page id, status code 201 when new page created" do
      expect(response.status).to eq(201)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq({ id: new_page.id })
    end

    it "creates DB row with new_page_params, fresh id, form_id set and next_page: nil" do
      expect(new_page.attributes.transform_keys(&:to_sym)).to eq(new_page_params.merge(id: new_page[:id], form_id: form[:id], next_page: nil))
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
        expect(json_body).to eq(page1.attributes.transform_keys(&:to_sym))
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

    let(:answer_type) { "single_line" }
    let(:answer_settings) { nil }
    let(:params) { { question_text: "updated page title", answer_type:, answer_settings: } }

    before do
      put "/api/v1/forms/#{form.id}/pages/#{page1.id}", params:, as: :json
    end

    it "returns correct response" do
      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq({ success: true })
      page1.reload
      expect(page1.question_text).to eq("updated page title")
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
          # require 'pry'; binding.pry
          expect(response.status).to eq(200)
          expect(response.headers["Content-Type"]).to eq("application/json")
          expect(json_body).to eq({ success: true })
          page1.reload
          expect(page1.answer_settings&.symbolize_keys).to eq(settings)
        end
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
end

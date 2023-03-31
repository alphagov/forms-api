require "rails_helper"

describe Api::V1::ConditionsController, type: :request do
  let(:json_body) { JSON.parse(response.body, symbolize_names: true) }
  let(:form) { create :form }
  let(:routing_page) { create :page, form: form }
  let(:goto_page) { create :page, form: form }

  describe "#index" do
    it "when no conditions exist for a page, returns 200 and an empty json array" do
      get "/api/v1/forms/#{form.id}/pages/#{routing_page.id}/conditions", as: :json
      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq([])
    end

    it "when given a form and page, returns a json array of conditions" do
      create :condition, routing_page: routing_page
      get "/api/v1/forms/#{form.id}/pages/#{routing_page.id}/conditions", as: :json
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body.count).to eq(routing_page.routing_conditions.count)
      routing_page.routing_conditions.each_with_index do |p, i|
        expect(json_body[i]).to eq(JSON.parse(p.to_json).symbolize_keys)
      end
    end
  end

  describe "#create" do
    let(:new_condition_params) do
      {
        routing_page_id: routing_page.id,
        check_page_id: routing_page.id,
        goto_page_id: goto_page.id,
        skip_to_end: false,
        answer_value: "hello",
      }
    end

    let(:new_condition) { routing_page.routing_conditions.first }

    before do
      post "/api/v1/forms/#{form.id}/pages/#{routing_page.id}/conditions", params: new_condition_params, as: :json
    end

    it "returns condition id, status code 201 when new condition created" do
      expect(response.status).to eq(201)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq({ id: new_condition.id })
    end

    context "with params missing required keys" do
      let(:new_condition_params) do
        { wrong: "" }
      end

      it "returns condition id, status code 400 and an array of messages" do
        expect(response.status).to eq(400)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq(error: "param is missing or the value is empty: condition")
      end

      it "does not create a new condition row" do
        condition_count = Condition.where(routing_page_id: routing_page.id).count
        expect(condition_count).to eq(0)
      end
    end
  end

#   describe "#show" do
#     let(:form) { create :form, :with_pages, pages_count: 2 }
#     let(:page1) { form.pages.first }
#     let(:page2) { form.pages[1] }

#     let(:form_id) { form.id }
#     let(:page_id) { page1.id }

#     before do
#       get "/api/v1/forms/#{form_id}/pages/#{page_id}", as: :json
#     end

#     context "when page exists" do
#       it "returns page, status code 200" do
#         expect(response.status).to eq(200)
#         expect(response.headers["Content-Type"]).to eq("application/json")
#         expect(json_body).to eq(JSON.parse(page1.to_json).symbolize_keys)
#       end
#     end

#     context "when page does not exist" do
#       let(:page_id) { 999 }

#       it "returns status code 404" do
#         expect(response.status).to eq(404)
#         expect(response.headers["Content-Type"]).to eq("application/json")
#         expect(json_body).to eq({ error: "not_found" })
#       end
#     end

#     context "when form does not exist" do
#       let(:form_id) { 999 }

#       it "returns a 404 with a json error" do
#         expect(response.status).to eq(404)
#         expect(response.headers["Content-Type"]).to eq("application/json")
#         expect(json_body).to eq({ error: "not_found" })
#       end
#     end
#   end

#   describe "#update" do
#     let(:form) { create :form, :with_pages, pages_count: 2 }
#     let(:page1) { form.pages.first }
#     let(:page2) { form.pages[1] }

#     let(:answer_type) { "national_insurance_number" }
#     let(:answer_settings) { nil }
#     let(:params) { { question_text: "updated page title", answer_type:, answer_settings: } }

#     before do
#       put "/api/v1/forms/#{form.id}/pages/#{page1.id}", params:, as: :json
#     end

#     it "returns correct response" do
#       expect(response.status).to eq(200)
#       expect(response.headers["Content-Type"]).to eq("application/json")
#       expect(json_body).to eq({ success: true })
#       expect(page1.reload.question_text).to eq("updated page title")
#       expect(form.reload.question_section_completed).to be false
#     end

#     it "fields not in the params are cleared" do
#       expect(page1.hint_text).to be_nil
#     end

#     [
#       ["selection",
#        {
#          only_one_option: "true",
#          selection_options: [{ "name" => "one" }, { "name" => "tw0" }],
#        }],
#       ["text",
#        {
#          input_type: "single_line",
#        }],
#       ["number", nil],
#     ].each do |type, settings|
#       context "with nested answer_settings" do
#         let(:answer_type) { type }
#         let(:answer_settings) { settings }

#         it "returns correct response" do
#           expect(response.status).to eq(200)
#           expect(response.headers["Content-Type"]).to eq("application/json")
#           expect(json_body).to eq({ success: true })
#           page1.reload
#           expect(page1.answer_settings&.symbolize_keys).to eq(settings)
#         end
#       end
#     end

#     context "with nested answer_settings and input_type" do
#       let(:answer_type) { "address" }
#       let(:answer_settings) do
#         {
#           input_type: {
#             uk_address: "true",
#             international_address: "true",
#           },
#         }
#       end

#       it "returns correct response" do
#         expect(response.status).to eq(200)
#         expect(response.headers["Content-Type"]).to eq("application/json")
#         expect(json_body).to eq({ success: true })
#         page1.reload
#         expect(page1.answer_settings&.deep_symbolize_keys).to eq(answer_settings)
#       end
#     end
#   end

#   describe "#destroy" do
#     let(:form) { create :form, :with_pages, pages_count: 2 }
#     let(:page1) { form.pages.first }
#     let(:page2) { form.pages[1] }

#     let(:form_id) { form.id }
#     let(:page_id) { page1.id }

#     before do
#       delete "/api/v1/forms/#{form_id}/pages/#{page_id}", as: :json
#     end

#     context "with exisitng page" do
#       it "removes page and returns correct response" do
#         expect(response.status).to eq(200)
#         expect(response.headers["Content-Type"]).to eq("application/json")
#         expect(json_body).to eq({ success: true })
#         expect(form.pages.count).to eq(1)
#         expect(form.reload.question_section_completed).to be false
#       end
#     end

#     context "with unknown form" do
#       let(:form_id) { 999 }

#       it "returns 404" do
#         expect(response.status).to eq(404)
#         expect(response.headers["Content-Type"]).to eq("application/json")
#         expect(json_body).to eq({ error: "not_found" })
#         expect(form.pages.count).to eq(2)
#       end
#     end

#     context "with unknown page" do
#       let(:page_id) { 999 }

#       it "returns 404" do
#         expect(response.status).to eq(404)
#         expect(response.headers["Content-Type"]).to eq("application/json")
#         expect(json_body).to eq({ error: "not_found" })
#         expect(form.pages.count).to eq(2)
#       end
#     end
#   end

#   describe "#move_down" do
#     let(:form_with_pages) { create :form, :with_pages }

#     let(:page_to_move) { form_with_pages.pages.first }
#     let(:first_page) { form_with_pages.pages.first }
#     let(:second_page) { form_with_pages.pages.second }
#     let(:third_page) { form_with_pages.pages.third }
#     let(:fourth_page) { form_with_pages.pages.fourth }
#     let(:last_page) { form_with_pages.pages.last }

#     before do
#       put "/api/v1/forms/#{form_with_pages.id}/pages/#{page_to_move.id}/down"
#     end

#     context "with valid page" do
#       it "returns correct response" do
#         expect(response.status).to eq(200)
#         expect(response.headers["Content-Type"]).to eq("application/json")
#         expect(json_body).to eq({ success: 1 })
#       end

#       it "changes order of pages returned" do
#         get "/api/v1/forms/#{form_with_pages.id}/pages"
#         expect(json_body.map { |p| p[:id] }).to eq([second_page.id, page_to_move.id, third_page.id, fourth_page.id, last_page.id])
#       end
#     end

#     context "with page already at the end of the list" do
#       let(:page_to_move) { last_page }

#       it "returns correct response" do
#         expect(response.status).to eq(200)
#         expect(response.headers["Content-Type"]).to eq("application/json")
#         expect(json_body).to eq({ success: 1 })
#       end

#       it "does not change order of pages" do
#         get "/api/v1/forms/#{form_with_pages.id}/pages"
#         expect(json_body.map { |p| p[:id] }).to eq([first_page.id, second_page.id, third_page.id, fourth_page.id, page_to_move.id])
#       end
#     end
#   end

#   describe "#move_up" do
#     let(:form_with_pages) { create :form, :with_pages }

#     let(:page_to_move) { second_page }
#     let(:first_page) { form_with_pages.pages.first }
#     let(:second_page) { form_with_pages.pages.second }
#     let(:third_page) { form_with_pages.pages.third }
#     let(:fourth_page) { form_with_pages.pages.fourth }
#     let(:last_page) { form_with_pages.pages.last }

#     before do
#       put "/api/v1/forms/#{form_with_pages.id}/pages/#{page_to_move.id}/up"
#     end

#     context "with valid page" do
#       it "returns correct response" do
#         expect(response.status).to eq(200)
#         expect(response.headers["Content-Type"]).to eq("application/json")
#         expect(json_body).to eq({ success: 1 })
#       end

#       it "changes order of pages returned" do
#         get "/api/v1/forms/#{form_with_pages.id}/pages"
#         expect(json_body.map { |p| p[:id] }).to eq([page_to_move.id, first_page.id, third_page.id, fourth_page.id, last_page.id])
#       end
#     end

#     context "with page already at the start of the list" do
#       let(:page_to_move) { first_page }

#       it "returns correct response" do
#         expect(response.status).to eq(200)
#         expect(response.headers["Content-Type"]).to eq("application/json")
#         expect(json_body).to eq({ success: 1 })
#       end

#       it "does not change order of pages" do
#         get "/api/v1/forms/#{form_with_pages.id}/pages"
#         expect(json_body.map { |p| p[:id] }).to eq([page_to_move.id, second_page.id, third_page.id, fourth_page.id, last_page.id])
#       end
#     end
#   end
end

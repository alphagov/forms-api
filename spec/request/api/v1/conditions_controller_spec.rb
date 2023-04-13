require "rails_helper"

describe Api::V1::ConditionsController, type: :request do
  let(:json_body) { JSON.parse(response.body, symbolize_names: true) }
  let(:form) { create :form }
  let(:routing_page) { create :page, form:, routing_conditions: [condition] }
  let(:goto_page) { create :page, form: }
  let(:condition) { create :condition }
  let(:condition_id) { condition.id }

  describe "#index" do
    context "when no conditions exist for a page" do
      let(:routing_page) { create :page, form: }

      it "returns 200 and an empty json array" do
        get "/api/v1/forms/#{form.id}/pages/#{routing_page.id}/conditions", as: :json
        expect(response.status).to eq(200)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq([])
      end
    end

    it "when given a form and page, returns a json array of conditions" do
      get "/api/v1/forms/#{form.id}/pages/#{routing_page.id}/conditions", as: :json
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body.count).to eq(routing_page.routing_conditions.count)
      routing_page.routing_conditions.each_with_index do |p, i|
        expect(json_body[i]).to eq(JSON.parse(p.to_json).symbolize_keys)
      end
    end
  end

  describe "#create" do
    let(:routing_page) { create :page, form: }

    let(:new_condition_params) do
      {
        routing_page_id: routing_page.id,
        check_page_id: routing_page.id,
        goto_page_id: goto_page.id,
        skip_to_end: false,
        answer_value: "hello",
      }
    end

    let(:new_condition) { routing_page.reload.routing_conditions.first }

    before do
      post "/api/v1/forms/#{form.id}/pages/#{routing_page.id}/conditions", params: new_condition_params, as: :json
    end

    it "returns condition id, status code 201 when new condition created" do
      expect(response.status).to eq(201)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq({ id: new_condition.id })
    end

    context "with a form with question_section_completed = true" do
      let(:form) { create :form, question_section_completed: true }

      it "marks sets the form's question_section_completed as false" do
        expect(form.reload.question_section_completed).to be false
      end
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

  describe "#show" do
    before do
      get "/api/v1/forms/#{form.id}/pages/#{routing_page.id}/conditions/#{condition_id}", as: :json
    end

    context "when the condition exists" do
      it "returns condition, status code 200" do
        expect(response.status).to eq(200)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq(JSON.parse(condition.to_json).symbolize_keys)
      end
    end

    context "when the condition does not exist" do
      let(:condition_id) { "banana" }

      it "returns status code 400" do
        expect(response.status).to eq(404)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq({ error: "not_found" })
      end
    end
  end

  describe "#update" do
    let(:params) { { answer_value: } }
    let(:answer_value) { "goodbye" }

    before do
      put "/api/v1/forms/#{form.id}/pages/#{routing_page.id}/conditions/#{condition_id}", params:, as: :json
    end

    it "returns correct response" do
      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq({ success: true })
      expect(condition.reload.answer_value).to eq(answer_value)
      expect(form.reload.question_section_completed).to be false
    end
  end

  describe "#destroy" do
    before do
      delete "/api/v1/forms/#{form.id}/pages/#{routing_page.id}/conditions/#{condition_id}", as: :json
    end

    it "removes the condition and returns the correct response" do
      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq({ success: true })
      expect(routing_page.routing_conditions.count).to eq(0)
      expect(form.reload.question_section_completed).to be false
    end
  end
end

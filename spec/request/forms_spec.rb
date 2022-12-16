require 'rails_helper'

describe "/api/v1/forms", type: :request do

  let(:json_body) { JSON.parse(response.body, symbolize_names: true) }

  before do
    # create_list :form, 2, org:"gds"
    create :form, org: "gds", name: 'test form 1'
    create :form, org: "gds", name: 'test form 2'
    create :form, org: "not-gds"
  end

  # around(:each) do |example|
  #   @database.transaction(rollback: :always) do
  #     @database[:forms].insert(name: "test form 1", submission_email: "", org: "gds")
  #     @database[:forms].insert(name: "test form 2", submission_email: "", org: "gds")
  #     @database[:forms].insert(name: "test form 3", submission_email: "", org: "not-gds")
  #     example.run
  #   end
  # end

  describe "get all forms" do
    it "when no forms exist for an org, returns 200 and an empty json array" do
      get "/api/v1/forms", params: { org: "unknown-org" }
      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq([])
    end

    it "when not given an org, returns 200 and an empty json array" do
      get "/api/v1/forms"
      expect(response.status).to eq(400)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq([{ messages: ["is missing"], params: ["org"] }])
    end

    it "when given an org with forms, returns a json array of forms" do
      get "/api/v1/forms", params: { org: "gds" }
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body.count).to eq(2)
      expect(response).to be_successful
      # FIXUP could be stronger?
      # changed from grape version
      json_body.each do |form|
        expect(form.keys).to contain_exactly(
          :id,
          :name,
          :submission_email,
          :org,
          :created_at,
          :live_at,
          :updated_at,
          :privacy_policy_url,
          :form_slug,
          :what_happens_next_text,
          :support_email,
          :support_phone,
          :support_url,
          :support_url_text,
          :declaration_text,
          :question_section_completed,
          :declaration_section_completed,
          :page_order)
      end
    end
  end

  describe "creating a form" do
    let(:created_form) { Form.find_by(name: "test form one")}
    let(:new_form_params) { { org: "gds", name: "test form one", submission_email: "test@example.gov.uk" } }

    before do
      post "/api/v1/forms", params: new_form_params
    end

    context "with valid params" do
      it "returns a status code 201 when new form created" do
        expect(response.status).to eq(201)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq(id: created_form[:id])
      end

      it "created the form in the DB" do
        expect(created_form[:name]).to eq("test form one")
        expect(created_form[:submission_email]).to eq("test@example.gov.uk")
        expect(created_form[:org]).to eq("gds")
      end
    end

    context "with invalid form params" do
      let(:new_form_params) {  }
      it "returns a status code 400" do
        expect(response.status).to eq(400)
        expect(response.headers["Content-Type"]).to eq("application/json")
      end
    end

    context "with no params" do
      let(:new_form_params) { {} }
      it "returns a status code 400" do
        expect(last_response.status).to eq(400)
        expect(last_response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq([{ messages: ["is missing"], params: ["name"] },
                                 { messages: ["is missing"], params: ["submission_email"] },
                                 { messages: ["is missing"], params: ["org"] }])
      end
    end

    context "with extra params" do
      let(:new_form_params) { { org: "gds", name: "test form one", submission_email: "test@example.gov.uk", support_url: "http://example.org" } }
      it "returns a status code 201" do
        expect(last_response.status).to eq(201)
        expect(last_response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq(id: created_form[:id])
      end

      it "created the form in the DB" do
        expect(created_form[:name]).to eq("test form one")
        expect(created_form[:submission_email]).to eq("test@example.gov.uk")
        expect(created_form[:org]).to eq("gds")
        expect(created_form[:support_url]).to eq(nil)
      end
    end
  end

  describe "get single form" do
    it "when no forms exists for an id, returns 404 and an empty json array" do
      get "/api/v1/forms/987"
      expect(last_response.status).to eq(404)
      expect(last_response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq(error: "not_found")
    end

    # This test is for documenting Grape API only
    it "when given an invalid id, returns 500 and an empty json array" do
      get "/api/v1/forms/invalid_id"
      expect(last_response.status).to eq(500)
      expect(last_response.headers["Content-Type"]).to eq("application/json")
    end

    it "when given an existing id, returns 200 and form data" do
      form1_id = @database[:forms].where(name: "test form 1").get(:id)
      get "/api/v1/forms/#{form1_id}"
      expect(last_response.status).to eq(200)
      expect(last_response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq({
                                id: form1_id,
                                name: "test form 1",
                                submission_email: "",
                                org: "gds",
                                created_at: nil,
                                live_at: nil,
                                updated_at: nil,
                                privacy_policy_url: nil,
                                form_slug: nil,
                                what_happens_next_text: nil,
                                support_email: nil,
                                support_phone: nil,
                                support_url: nil,
                                support_url_text: nil,
                                declaration_text: nil,
                                question_section_completed: false,
                                declaration_section_completed: false,
                                page_order: [],
                                start_page: nil
                              })
    end
  end

  describe "update single form" do
    it "when no forms exists for an id, returns 404 an error" do
      put "/api/v1/forms/123", {}
      expect(last_response.status).to eq(404)
      expect(last_response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq(error: "not_found")
    end

    it "when given an invalid key, returns 400 and an array of messages" do
      form1_id = @database[:forms].where(name: "test form 1").get(:id)
      put "/api/v1/forms/#{form1_id}", { invalid: "invalid key" }
      expect(last_response.status).to eq(400)
      expect(last_response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq([
                                { messages: ["is missing"], params: ["name"] },
                                { messages: ["is missing"], params: ["submission_email"] },
                                { messages: ["is missing"], params: ["org"] },
                                { messages: ["is missing"], params: ["live_at"] }
                              ])
    end

    it "when given an valid id and params, updates DB and returns 200" do
      form1_id = @database[:forms].where(name: "test form 1").get(:id)
      put "/api/v1/forms/#{form1_id}", { name: "test1", org: "gds", live_at: nil, submission_email: "test@example.gov.uk" }
      expect(last_response.status).to eq(200)
      expect(last_response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq(success: true)
      form = database[:forms].where(id: form1_id).get(:submission_email)
      expect(form).to eq("test@example.gov.uk")
    end
  end

  describe "delete a form" do
    it "when no forms exists for an id, returns 404 an error" do
      delete "/api/v1/forms/123", {}
      expect(last_response.status).to eq(404)
      expect(last_response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq(error: "not_found")
    end

    it "when given an existing id, returns 200 and deletes the form from DB" do
      form1_id = @database[:forms].where(name: "test form 1").get(:id)
      delete "/api/v1/forms/#{form1_id}", {}
      expect(last_response.status).to eq(200)
      expect(last_response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq({ success: true })
    end
  end
end

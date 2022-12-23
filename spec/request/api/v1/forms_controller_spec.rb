require "rails_helper"

headers = {
  "ACCEPT" => "application/json",
}

describe Api::V1::FormsController, type: :request do
  let(:json_body) { JSON.parse(response.body, symbolize_names: true) }

  before do
    create_list :form, 2, org: "gds"
    create :form, org: "not-gds"
  end

  describe "#index" do
    it "when no forms exist for an org, returns 200 and an empty json array" do
      get "/api/v1/forms", params: { org: "unknown-org" }, headers: headers
      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq([])
    end

    it "when not given an org, returns 200 and an empty json array" do
      get "/api/v1/forms", headers: headers
      expect(response.status).to eq(400)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq({ error: "param is missing or the value is empty: org" })
    end

    it "when given an org with forms, returns a json array of forms" do
      get "/api/v1/forms", params: { org: "gds" }, headers: headers
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
          :page_order,
        )
      end
    end
  end

  describe "#create" do
    let(:created_form) { Form.find_by(name: "test form one") }
    let(:new_form_params) { { org: "gds", name: "test form one", submission_email: "test@example.gov.uk" } }

    before do
      post "/api/v1/forms", params: new_form_params, as: :json
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

    context "with no params" do
      let(:new_form_params) { {} }

      it "returns a status code 400 and validation messages" do
        expect(response.status).to eq(400)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq({ error: "param is missing or the value is empty: form" })
      end
    end

    context "with extra params" do
      let(:new_form_params) { { org: "gds", name: "test form one", submission_email: "test@example.gov.uk", support_url: "http://example.org" } }

      it "returns a status code 201" do
        expect(response.status).to eq(201)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq(id: created_form[:id])
      end

      it "created the form in the DB" do
        expect(created_form[:name]).to eq("test form one")
        expect(created_form[:submission_email]).to eq("test@example.gov.uk")
        expect(created_form[:org]).to eq("gds")
        expect(created_form[:support_url]).to eq("http://example.org")
      end
    end
  end

  describe "#show" do
    it "when no forms exists for an id, returns 404 and an empty json array" do
      get "/api/v1/forms/987", as: :json
      expect(response.status).to eq(404)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq(error: "not_found")
    end

    # This test is for documenting Grape API only
    it "when given an invalid id, returns 500 and an empty json array" do
      get "/api/v1/forms/invalid_id", as: :json
      expect(response.status).to eq(404)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq(error: "not_found")
    end

    it "when given an existing id, returns 200 and form data" do
      form1 = Form.create!(name: "test form 1", org: "gds")
      get "/api/v1/forms/#{form1.id}", as: :json
      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/json")

      expect(json_body).to match(
        id: form1.id,
        name: "test form 1",
        submission_email: nil,
        org: "gds",
        live_at: nil,
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
        page_order: nil,
        created_at: form1.created_at.to_s,
        updated_at: form1.updated_at.to_s,
      )
    end
  end

  describe "#update" do
    it "when no forms exists for an id, returns 404 an error" do
      put "/api/v1/forms/123", as: :json
      expect(response.status).to eq(404)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq(error: "not_found")
    end

    it "when given an valid id and params, updates DB and returns 200" do
      form1 = create :form
      put "/api/v1/forms/#{form1.id}", params: { submission_email: "test@example.gov.uk" }, as: :json
      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq(success: true)
      expect(form1.reload.submission_email).to eq("test@example.gov.uk")
    end
  end

  describe "#destroy" do
    it "when no forms exists for an id, returns 404 an error" do
      delete "/api/v1/forms/123", as: :json
      expect(response.status).to eq(404)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq(error: "not_found")
    end

    it "when given an existing id, returns 200 and deletes the form from DB" do
      form_to_be_deleted = create :form
      delete "/api/v1/forms/#{form_to_be_deleted.id}", as: :json
      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq({ success: true })
    end
  end
end

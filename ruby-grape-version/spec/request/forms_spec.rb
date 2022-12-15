require "rack/test"

describe "/api/v1/forms" do
  include Rack::Test::Methods
  include_context "with database"

  def app
    Server::Server
  end

  let(:json_body) { JSON.parse(last_response.body, symbolize_names: true) }

  before(:each) do
    stub_const("ENV", ENV.to_hash.merge("API_KEY" => "an-api-key"))
    allow(Database).to receive(:existing_database).and_return(@database)
    header "X-Api-Token", ENV["API_KEY"]
  end

  around(:each) do |example|
    @database.transaction(rollback: :always) do
      @database[:forms].insert(name: "test form 1", submission_email: "", org: "gds")
      @database[:forms].insert(name: "test form 2", submission_email: "", org: "gds")
      @database[:forms].insert(name: "test form 3", submission_email: "", org: "not-gds")
      example.run
    end
  end

  describe "get all forms" do
    it "when no forms exist for an org, returns 200 and an empty json array" do
      get "/api/v1/forms", { org: "unknown-org" }
      expect(last_response.status).to eq(200)
      expect(last_response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq([])
    end

    it "when not given an org, returns 200 and an empty json array" do
      get "/api/v1/forms", {}
      expect(last_response.status).to eq(400)
      expect(last_response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq([{ messages: ["is missing"], params: ["org"] }])
    end

    # rubocop:disable Metrics/BlockLength
    it "when given an org with forms, returns a json array of forms" do
      get "/api/v1/forms", { org: "gds" }
      expect(last_response.headers["Content-Type"]).to eq("application/json")
      expect(json_body.count).to eq(2)
      form1_id = @database[:forms].where(name: "test form 1").get(:id)
      form2_id = @database[:forms].where(name: "test form 2").get(:id)
      expect(json_body).to eq([
                                {
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
                                  page_order: []
                                },
                                {
                                  id: form2_id,
                                  name: "test form 2",
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
                                  page_order: []
                                }
                              ])
    end
    # rubocop:enable Metrics/BlockLength
  end

  describe "creating a form" do
    let(:created_form) { database[:forms].where(name: "test form one").all.last }
    let(:new_form_params) { { org: "gds", name: "test form one", submission_email: "test@example.gov.uk" } }

    before do
      post "/api/v1/forms", new_form_params
    end

    context "with valid params" do
      it "returns a status code 201 when new form created" do
        expect(last_response.status).to eq(201)
        expect(last_response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq(id: created_form[:id])
      end

      it "created the form in the DB" do
        expect(created_form[:name]).to eq("test form one")
        expect(created_form[:submission_email]).to eq("test@example.gov.uk")
        expect(created_form[:org]).to eq("gds")
      end
    end

    context "with no org" do
      let(:new_form_params) { { name: "test form one", submission_email: "test@example.gov.uk" } }
      it "returns a status code 400" do
        expect(last_response.status).to eq(400)
        expect(last_response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq([{ messages: ["is missing"], params: ["org"] }])
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

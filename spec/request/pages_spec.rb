require "rack/test"

describe "/api/v1/pages" do
  include Rack::Test::Methods
  include_context "with database"

  def app
    Server::Server
  end

  let(:json_body) { JSON.parse(last_response.body, symbolize_names: true) }

  let(:form_with_pages_id) { database[:forms].where(name: "test form 1").get(:id) }
  let(:page_id) { database[:pages].where(question_text: "What is your first name?", form_id: form_with_pages_id).get(:id) }
  let(:page2_id) { database[:pages].where(question_text: "What is your second name?", form_id: form_with_pages_id).get(:id) }
  let(:pages_for_a_specific_form) { database[:pages].where(form_id: form_with_pages_id).all }

  let(:new_page_params) do
    {
      form_id: form_with_pages_id,
      question_text: "What is your first name?",
      question_short_name: "",
      hint_text: "Should be first/last name",
      answer_type: "single_line",
      is_optional: false,
      answer_settings: nil
    }
  end

  let(:new_page2_params) do
    {
      form_id: form_with_pages_id,
      question_text: "What is your second name?",
      hint_text: "Should be first/last name",
      answer_type: "single_line",
      question_short_name: "",
      is_optional: false,
      answer_settings: nil
    }
  end

  before(:each) do
    stub_const("ENV", ENV.to_hash.merge("API_KEY" => "an-api-key"))
    allow(Database).to receive(:existing_database).and_return(@database)
    header "X-Api-Token", ENV["API_KEY"]
  end

  around(:each) do |example|
    @database.transaction(rollback: :always) do
      form_id = @database[:forms].insert(name: "test form 1", submission_email: "", org: "gds")
      page1_id = @database[:pages].insert(new_page_params)
      page2_id = @database[:pages].insert(new_page2_params)

      @database[:forms].where(id: form_id).update(page_order: Sequel.pg_array([page1_id, page2_id]))
      @database[:forms].insert(name: "form with no pages", submission_email: "", org: "gds")
      @database[:forms].insert(name: "test form 3", submission_email: "", org: "not-gds")
      example.run
    end
  end

  describe "get all pages for a form" do
    it "when no pages exist for a form, returns 200 and an empty json array" do
      form_id = database[:forms].where(name: "form with no pages").get(:id)
      get "/api/v1/forms/#{form_id}/pages"
      expect(last_response.status).to eq(200)
      expect(last_response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq([])
    end

    it "when given a form, returns a json array of pages" do
      get "/api/v1/forms/#{form_with_pages_id}/pages"
      expect(last_response.headers["Content-Type"]).to eq("application/json")
      expect(json_body.count).to eq(2)
      pages_for_a_specific_form.first[:next_page] = page2_id # FIXUP We will be merging into forms and converting to json column so this shouldn't need tweaking in the future
      expect(json_body).to eq(pages_for_a_specific_form)
    end
  end

  describe "creating a page" do
    let(:form3) { database[:forms].where(name: "test form 3").all.last }
    let(:new_page) { database[:pages].where(form_id: form3[:id]).first }

    before do
      post "/api/v1/forms/#{form3[:id]}/pages", new_page_params
    end

    context "with valid params" do
      it "returns page id, status code 201 when new page created" do
        expect(last_response.status).to eq(201)
        expect(last_response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq({ id: new_page[:id] })
      end

      it "creates DB row with new_page_params, fresh id, form_id set and next_page: nil" do
        db_page = database[:pages].where(form_id: form3[:id]).first
        expect(db_page).to eq(new_page_params.merge(id: new_page[:id], form_id: form3[:id], next_page: nil))
      end
    end

    context "with params missing required keys" do
      let(:new_page_params) do
        {}
      end
      it "returns page id, status code 400 and an array of messages" do
        expect(last_response.status).to eq(400)
        expect(last_response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq([{ messages: ["is missing"], params: ["question_text"] },
                                 { messages: ["is missing", "does not have a valid value"], params: ["answer_type"] }])
      end

      it "does not create a new page row" do
        page_count = database[:pages].where(form_id: form3[:id]).count
        expect(page_count).to eq(0)
      end
    end

    describe "get a page" do
      let(:form_id) { form_with_pages_id }
      before do
        get "/api/v1/forms/#{form_id}/pages/#{page_id}"
      end

      context "when page exists" do
        it "returns page, status code 200" do
          expect(last_response.status).to eq(200)
          expect(last_response.headers["Content-Type"]).to eq("application/json")
          expect(json_body).to eq(new_page_params.merge(form_id:, id: page_id, next_page: page2_id))
        end
      end

      # FIXUP We don't want to replicate this - it's a bug - should return an empty 404!
      context "when page does not exist" do
        let(:page_id) { 999 }
        it "returns page, status code 500" do
          expect(last_response.status).to eq(500)
          expect(last_response.headers["Content-Type"]).to eq("application/json")
        end
      end

      context "when form does not exist" do
        let(:form_id) { 999 }
        it "returns a 404 with a json error" do
          expect(last_response.status).to eq(404)
          expect(last_response.headers["Content-Type"]).to eq("application/json")
          expect(json_body).to eq({ error: "not_found" })
        end
      end
    end

    describe "move page down" do
      let(:page_to_move) { page_id }
      before do
        put "/api/v1/forms/#{form_with_pages_id}/pages/#{page_to_move}/down", {}
      end

      context "with valid page" do
        it "returns correct response" do
          expect(last_response.status).to eq(200)
          expect(last_response.headers["Content-Type"]).to eq("application/json")
          expect(json_body).to eq({ success: 1 })
        end

        it "changes order of pages returned" do
          get "/api/v1/forms/#{form_with_pages_id}/pages"
          expect(json_body.map { |p| p[:id] }).to eq([page2_id, page_id])
        end
      end

      context "with page already at the end of the list" do
        let(:page_to_move) { page2_id }

        it "returns correct response" do
          expect(last_response.status).to eq(200)
          expect(last_response.headers["Content-Type"]).to eq("application/json")
          expect(json_body).to eq({ success: 1 })
        end

        it "does not change order of pages" do
          get "/api/v1/forms/#{form_with_pages_id}/pages"
          expect(json_body.map { |p| p[:id] }).to eq([page_id, page2_id])
        end
      end
    end

    describe "move page up" do
      let(:page_to_move) { page2_id }

      before do
        put "/api/v1/forms/#{form_with_pages_id}/pages/#{page_to_move}/up", {}
      end

      context "with valid page" do
        it "returns correct response" do
          expect(last_response.status).to eq(200)
          expect(last_response.headers["Content-Type"]).to eq("application/json")
          expect(json_body).to eq({ success: 1 })
        end

        it "changes order of pages returned" do
          get "/api/v1/forms/#{form_with_pages_id}/pages"
          expect(json_body.map { |p| p[:id] }).to eq([page2_id, page_id])
        end
      end

      context "with page already at the start of the list" do
        let(:page_to_move) { page_id }

        it "returns correct response" do
          expect(last_response.status).to eq(200)
          expect(last_response.headers["Content-Type"]).to eq("application/json")
          expect(json_body).to eq({ success: 1 })
        end

        it "does not change order of pages" do
          get "/api/v1/forms/#{form_with_pages_id}/pages"
          expect(json_body.map { |p| p[:id] }).to eq([page_id, page2_id])
        end
      end
    end

    describe "update page" do
      let(:params) { { question_text: "updated page title", answer_type: "single_line" } }

      before do
        put "/api/v1/forms/#{form_with_pages_id}/pages/#{page_id}", params
      end

      it "returns correct response" do
        expect(last_response.status).to eq(200)
        expect(last_response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq({ success: true })
      end

      it "the page to be updated in the database" do
        expect(database[:pages].where(id: page_id).get(:question_text)).to eq("updated page title")
      end

      it "fields not in the params are cleared" do
        expect(database[:pages].where(id: page_id).get(:hint_text)).to be_nil
      end

      context "with empty params" do
        let(:params) { {} }

        it "returns correct response" do
          expect(last_response.status).to eq(400)
          expect(last_response.headers["Content-Type"]).to eq("application/json")
          expect(json_body).to eq([{ messages: ["is missing"], params: ["question_text"] },
                                   { messages: ["is missing", "does not have a valid value"], params: ["answer_type"] }])
        end
      end
    end

    describe "delete page" do
      before do
        delete "/api/v1/forms/#{form_with_pages_id}/pages/#{page_id}"
      end

      it "returns correct response" do
        expect(last_response.status).to eq(200)
        expect(last_response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq({ success: true })
      end

      it "page to be removed from database" do
        expect(database[:pages].where(id: page_id).first).to be_nil
      end
    end
  end
end

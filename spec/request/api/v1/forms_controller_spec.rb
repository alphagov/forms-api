require "rails_helper"

headers = {
  "ACCEPT" => "application/json",
}

describe Api::V1::FormsController, type: :request do
  let(:json_body) { JSON.parse(response.body, symbolize_names: true) }
  let(:gds_forms) do
    [
      create(:form, name: "Fill me in", org: "gds"),
      create(:form, name: "Can you answer my questions?", org: "gds"),
    ]
  end

  before do
    gds_forms
    create :form, org: "not-gds"
  end

  describe "#index" do
    it "when no forms exist for an org, returns 200 and an empty json array" do
      get forms_path, params: { org: "unknown-org" }, headers: headers
      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq([])
    end

    it "when not given an org, returns 200 and an empty json array" do
      get forms_path, headers: headers
      expect(response.status).to eq(400)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq({ error: "param is missing or the value is empty: org" })
    end

    it "when given an org with forms, returns a json array of forms" do
      get forms_path, params: { org: "gds" }, headers: headers
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
          :start_page,
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

    describe "ordering of forms" do
      it "returns a list of forms sorted in alphabetical order" do
        get forms_path, params: { org: "gds" }, headers: headers
        expect(response.status).to eq(200)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body.pluck(:name)).to eq(gds_forms.sort_by(&:name).pluck(:name))
      end
    end
  end

  describe "#create" do
    let(:created_form) { Form.find_by(name: "test form one") }
    let(:new_form_params) { { org: "gds", name: "test form one", submission_email: "test@example.gov.uk" } }

    before do
      freeze_time
      post forms_path, params: new_form_params, as: :json
    end

    after do
      unfreeze_time
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

    context "with created_at and updated_at params" do
      let(:new_form_params) { { org: "gds", name: "test form one", submission_email: "test@example.gov.uk", created_at: "2023-01-11T16:22:22.661+00:00", updated_at: "2023-01-11T16:24:22.661+00:00" } }

      it "does not use the provided created_at or updated_at values" do
        expect(response.status).to eq(201)
        expect(created_form[:created_at]).to eq(Time.current)
        expect(created_form[:updated_at]).to eq(Time.current)
      end
    end
  end

  describe "#show" do
    it "when no forms exists for an id, returns 404 and an empty json array" do
      get form_path(id: 987), as: :json
      expect(response.status).to eq(404)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq(error: "not_found")
    end

    # This test is for documenting Grape API only
    it "when given an invalid id, returns 500 and an empty json array" do
      get form_path(id: "invalid_id"), as: :json
      expect(response.status).to eq(404)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq(error: "not_found")
    end

    it "when given an existing id, returns 200 and form data" do
      form1 = Form.create!(name: "test form 1", org: "gds")
      get form_path(form1), as: :json
      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/json")

      expect(json_body).to match(
        id: form1.id,
        name: "test form 1",
        submission_email: nil,
        org: "gds",
        live_at: nil,
        privacy_policy_url: nil,
        form_slug: "test-form-1",
        start_page: nil,
        what_happens_next_text: nil,
        support_email: nil,
        support_phone: nil,
        support_url: nil,
        support_url_text: nil,
        declaration_text: nil,
        question_section_completed: false,
        declaration_section_completed: false,
        page_order: nil,
        created_at: form1.created_at.as_json,
        updated_at: form1.updated_at.as_json,
      )
    end
  end

  describe "#show_live", versioning: true do
    it "when given an existing id, returns 200 and form data for current live version" do
      form1 = Form.create!(name: "test form 1", org: "gds")
      form1.make_live!
      get live_form_path(form1), as: :json
      expect(response.status).to eq(200)
    end

    # TODO: add this back in once we have live versions of a form
    xit "when given an existing id, returns 404 if form does not have live version" do
      form1 = Form.create!(name: "test form 1", org: "gds")
      get live_form_path(form1), as: :json
      expect(response.status).to eq(404)
    end
  end

  describe "#update" do
    it "when no forms exists for an id, returns 404 an error" do
      put form_path(123), as: :json
      expect(response.status).to eq(404)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq(error: "not_found")
    end

    it "when given an valid id and params, updates DB and returns 200" do
      form1 = create :form
      put form_path(form1), params: { submission_email: "test@example.gov.uk" }, as: :json
      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq(success: true)
      expect(form1.reload.submission_email).to eq("test@example.gov.uk")
    end

    it "ignores created_at" do
      form1 = create :form
      expect { put form_path(form1), params: { created_at: "2023-01-11T16:22:22.661+00:00" }, as: :json }.not_to(change { form1.reload.created_at })
    end

    it "ignores updated_at" do
      form1 = create :form
      expect { put form_path(form1), params: { updated_at: "2023-01-11T16:22:22.661+00:00" }, as: :json }.not_to(change { form1.reload.updated_at })
    end

    context "when a form creator makes their form live" do
      context "when feature_draft_live_versioning is not enabled", feature_draft_live_versioning: false do
        it "sets live_at for a form when draft_live_versioning is not enabled" do
          travel_to Time.zone.local(2023, 1, 1, 12, 0, 0) do
            form1 = create :form, :ready_for_live
            live_at = Time.zone.now

            put form_path(form1), params: { live_at: live_at }, as: :json
            expect(form1.reload.live_at).to eq live_at
          end
        end
      end

      context "when feature_draft_live_versioning is enabled", feature_draft_live_versioning: true, versioning: true do

        let(:live_at) { Time.zone.local(2023, 1, 1, 12, 0, 0) }

        it "does not create a version if live_at is set" do
          travel_to live_at do
            form1 = create :form, :ready_for_live

            put form_path(form1), params: { live_at: live_at }, as: :json
            expect(form1.reload.versions.where(event: :update).length).to eq 0
          end
        end

        it "sets live_at for a form when draft_live_versioning is enabled" do
          travel_to live_at do
            form1 = create :form, :ready_for_live

            put form_path(form1), params: { live_at: live_at }, as: :json
            expect(form1.reload.live_at).to eq live_at
          end
        end
      end
    end
  end

  describe "#destroy" do
    it "when no forms exists for an id, returns 404 an error" do
      delete form_path(123), as: :json
      expect(response.status).to eq(404)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq(error: "not_found")
    end

    it "when given an existing id, returns 200 and deletes the form from DB" do
      form_to_be_deleted = create :form
      delete form_path(form_to_be_deleted), as: :json
      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq({ success: true })
    end

    it "when given an existing id, returns 200 and deletes the form and any existing pages from DB" do
      form_to_be_deleted = create :form, :with_pages
      delete form_path(form_to_be_deleted), as: :json
      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq({ success: true })
    end
  end

  describe "#make_live" do
    it "when given a form, sets live_at to current time" do
      form_to_be_made_live = create :form
      post make_live_form_path(form_to_be_made_live), as: :json
      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq({ success: true })
    end
  end

  describe "#show_live" do
    it "returns a form with all its pages" do
      form = create :form, :with_pages, :live

      get live_form_path(form), as: :json

      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/json")

      expect(json_body[:pages].pluck(:question_text)).to match form.pages.select(:question_text).pluck(:question_text)
    end

    it "returns 404 if live form doesn't exist" do
      get live_form_path(1), as: :json

      expect(response.status).to eq(404)
      expect(response.headers["Content-Type"]).to eq("application/json")
    end
  end
end

require "rails_helper"

headers = {
  "ACCEPT" => "application/json",
}

describe Api::V1::FormsController, type: :request do
  let(:json_body) { JSON.parse(response.body, symbolize_names: true) }
  let(:gds_forms) do
    [
      create(:form, name: "Fill me in", organisation_id: 1),
      create(:form, name: "Can you answer my questions?", organisation_id: 1),
    ]
  end
  let(:other_org_forms) { create :form, creator_id: 123, organisation_id: 2 }
  let(:user_form) { create :form, creator_id: 123, organisation_id: nil }
  let(:other_user_form) { create :form, creator_id: 1234, organisation_id: nil }

  let(:all_forms) do
    gds_forms + [other_org_forms, user_form, other_user_form]
  end

  before do
    all_forms
  end

  describe "#append_info_to_payload" do
    it "adds :id to payload as :form_id" do
      payload = nil
      ActiveSupport::Notifications.subscribe("process_action.action_controller") do |_name, _start, _finish, _id, payload_|
        payload = payload_
      end

      get form_path(id: 987), as: :json

      expect(payload).to include form_id: "987"
    end
  end

  describe "#index" do
    it "when no forms exist for an organisation, returns 200 and an empty json array" do
      get(forms_path, params: { organisation_id: 3 }, headers:)
      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq([])
    end

    it "when not given an organisation, returns 200 forms and forms for all orgs." do
      get(forms_path, headers:)
      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body.length).to eq 5
    end

    it "when given an organisation with forms, returns a json array of forms" do
      get(forms_path, params: { organisation_id: 1 }, headers:)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body.count).to eq(2)
      expect(response).to be_successful

      expect(json_body[0]).to include(name: "Can you answer my questions?")
      expect(json_body[1]).to include(name: "Fill me in")
    end

    it "when given a creator with forms, returns a json array of forms" do
      get(forms_path, params: { creator_id: 123 }, headers:)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body.count).to eq(2)
      expect(response).to be_successful

      json_body.each do |form|
        expect(form[:creator_id]).to eq(123)
      end
    end

    it "when given an organisation and a creator with forms, returns a json array of forms" do
      get(forms_path, params: { creator_id: 123, organisation_id: 2 }, headers:)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body.count).to eq(1)
      expect(response).to be_successful

      json_body.each do |form|
        expect(form[:creator_id]).to eq(123)
        expect(form[:organisation_id]).to eq(2)
      end
    end

    describe "ordering of forms" do
      it "returns a list of forms sorted in alphabetical order" do
        get(forms_path, params: { organisation_id: 1 }, headers:)
        expect(response.status).to eq(200)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body.pluck(:name)).to eq(gds_forms.sort_by(&:name).pluck(:name))
      end
    end
  end

  describe "#create" do
    let(:created_form) { Form.find_by(name: "test form one") }
    let(:new_form_params) { { organisation_id: 1, name: "test form one", submission_email: "test@example.gov.uk" } }

    before do
      freeze_time
      post forms_path, params: new_form_params, as: :json
    end

    after do
      unfreeze_time
    end

    context "with valid params" do
      it "returns a status code 201 when new form created" do
        expect(response).to have_http_status(:created)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to include(id: created_form[:id], **new_form_params)
      end

      it "created the form in the DB" do
        expect(created_form[:name]).to eq("test form one")
        expect(created_form[:submission_email]).to eq("test@example.gov.uk")
        expect(created_form[:organisation_id]).to eq(1)
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
      let(:new_form_params) { { organisation_id: 1, name: "test form one", submission_email: "test@example.gov.uk", support_url: "http://example.org" } }

      it "returns a status code 201" do
        expect(response).to have_http_status(:created)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to include(id: created_form[:id], **new_form_params)
      end

      it "created the form in the DB" do
        expect(created_form[:name]).to eq("test form one")
        expect(created_form[:submission_email]).to eq("test@example.gov.uk")
        expect(created_form[:organisation_id]).to eq(1)
        expect(created_form[:support_url]).to eq("http://example.org")
      end
    end

    context "with created_at and updated_at params" do
      let(:new_form_params) { { organisation_id: 1, name: "test form one", submission_email: "test@example.gov.uk", created_at: "2023-01-11T16:22:22.661+00:00", updated_at: "2023-01-11T16:24:22.661+00:00" } }

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
      form1 = Form.create!(name: "test form 1", organisation_id: 1, creator_id: 123)
      get form_path(form1), as: :json
      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/json")

      expect(json_body).to match(
        id: form1.id,
        name: "test form 1",
        submission_email: nil,
        organisation_id: 1,
        creator_id: 123,
        has_draft_version: true,
        has_live_version: false,
        live_at: nil,
        privacy_policy_url: nil,
        form_slug: "test-form-1",
        start_page: nil,
        what_happens_next_markdown: nil,
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
        has_routing_errors: false,
        incomplete_tasks: %w[missing_pages missing_what_happens_next missing_privacy_policy_url missing_contact_details],
        ready_for_live: false,
        task_statuses: { declaration_status: "not_started", make_live_status: "cannot_start", name_status: "completed", pages_status: "not_started", privacy_policy_status: "not_started", support_contact_details_status: "not_started", what_happens_next_status: "not_started" },
      )
    end
  end

  describe "#update" do
    it "when no forms exists for an id, returns 404 an error" do
      put form_path(id: 999), as: :json
      expect(response.status).to eq(404)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq(error: "not_found")
    end

    it "when given an valid id and params, updates DB and returns 200" do
      form1 = create :form
      put form_path(form1), params: { submission_email: "test@example.gov.uk" }, as: :json
      expect(response).to have_http_status(:ok)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to include(submission_email: "test@example.gov.uk")
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
      expect(response).to have_http_status(:no_content)
    end

    it "when given an existing id, returns 200 and deletes the form and any existing pages from DB" do
      form_to_be_deleted = create :form, :with_pages
      delete form_path(form_to_be_deleted), as: :json
      expect(response).to have_http_status(:no_content)
    end
  end

  describe "#make_live" do
    before do
      freeze_time
    end

    after do
      unfreeze_time
    end

    context "when given a form with missing sections" do
      it "doesn't make the form live" do
        form_to_be_made_live = create(:form, :new_form)
        post make_live_form_path(form_to_be_made_live), as: :json
        expect(response.status).to eq(403)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq(%w[missing_pages missing_what_happens_next missing_privacy_policy_url missing_contact_details])
      end
    end

    it "when given a form, sets live_at to current time" do
      form_to_be_made_live = create(:form, :ready_for_live)
      post make_live_form_path(form_to_be_made_live), as: :json
      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to include(live_at: Time.zone.now)
    end
  end

  describe "make unlive" do
    it "makes a live form unlive" do
      form = (create :made_live_form).form
      post make_unlive_form_path(form), as: :json

      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to include(live_at: nil)
    end
  end

  describe "#show_live" do
    it "returns the actual made live version which includes pages" do
      made_live_form = create :made_live_form
      made_live_form.form.update!(name: "Updated form")

      get live_form_path(made_live_form.form), as: :json

      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/json")

      expect(json_body.to_json).to eq made_live_form.json_form_blob
    end

    it "returns 404 if live form doesn't exist" do
      get live_form_path(1), as: :json

      expect(response.status).to eq(404)
      expect(response.headers["Content-Type"]).to eq("application/json")
    end

    it "returns 404 if form has never existed" do
      form = create :form
      get live_form_path(form.id), as: :json

      expect(response.status).to eq(404)
      expect(response.headers["Content-Type"]).to eq("application/json")
    end
  end

  describe "#show_draft" do
    it "returns the draft version which includes pages" do
      draft_form = create :form, :ready_for_live

      get draft_form_path(draft_form), as: :json

      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to eq("application/json")

      expect(json_body.to_json).to eq draft_form.snapshot.to_json
    end

    it "returns 404 if draft form doesn't exist" do
      get draft_form_path(1), as: :json

      expect(response.status).to eq(404)
      expect(response.headers["Content-Type"]).to eq("application/json")
    end
  end

  describe "#update_organisation_for_creator" do
    let(:selected_creator_id) { 1234 }
    let(:updated_organisation_id) { 111 }

    before do
      patch update_organisation_for_creator_forms_path, params: { creator_id: selected_creator_id, organisation_id: updated_organisation_id }
    end

    context "when some forms match creator ID" do
      it "updates organisation only if creator ID matches" do
        expect(response).to have_http_status(:no_content)

        all_forms.each do |form|
          form.reload
          if form.creator_id == selected_creator_id
            expect(form.organisation_id).to eq(updated_organisation_id)
          else
            expect(form.organisation_id).not_to eq(updated_organisation_id)
          end
        end
      end
    end

    context "when no forms match creator ID" do
      let(:selected_creator_id) { 321 }

      it "does not update organisation" do
        expect(response).to have_http_status(:no_content)

        all_forms.each do |form|
          form.reload
          expect(form.organisation_id).not_to eq(updated_organisation_id)
        end
      end
    end

    context "without creator ID" do
      let(:selected_creator_id) { nil }

      it "returns bad request if creator ID is missing" do
        expect(response).to have_http_status(:bad_request)
      end
    end

    context "without organisation ID" do
      let(:updated_organisation_id) { nil }

      it "returns bad request if organisation ID is missing" do
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end

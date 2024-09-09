require "rails_helper"

headers = {
  "ACCEPT" => "application/json",
}

describe Api::V1::FormsController, type: :request do
  let(:json_body) { JSON.parse(response.body, symbolize_names: true) }
  let(:user_forms) do
    [
      create(:form, name: "Fill me in", creator_id: 123),
      create(:form, name: "Can you answer my questions?", creator_id: 123),
    ]
  end
  let(:other_user_form) { create :form, creator_id: 1234 }

  let(:all_forms) do
    user_forms + [other_user_form]
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
    it "when not given any query params, returns 200 status and all forms." do
      get(forms_path, headers:)
      expect(response).to have_http_status(:ok)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body.length).to eq 3
    end

    it "when given a creator with forms, returns a json array of forms" do
      get(forms_path, params: { creator_id: 123 }, headers:)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body.count).to eq(2)
      expect(response).to be_successful

      expect(json_body[0]).to include(name: "Can you answer my questions?", creator_id: 123)
      expect(json_body[1]).to include(name: "Fill me in", creator_id: 123)
    end

    describe "ordering of forms" do
      it "returns a list of forms sorted in alphabetical order" do
        get(forms_path, params: { creator_id: 123 }, headers:)
        expect(response).to have_http_status(:ok)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body.pluck(:name)).to eq(user_forms.sort_by(&:name).pluck(:name))
      end
    end
  end

  describe "#create" do
    let(:created_form) { Form.find_by(name: "test form one") }
    let(:new_form_params) { { name: "test form one", submission_email: "test@example.gov.uk" } }

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
      end
    end

    context "with no params" do
      let(:new_form_params) { {} }

      it "returns a status code 400 and validation messages" do
        expect(response).to have_http_status(:bad_request)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq({ error: "param is missing or the value is empty: form" })
      end
    end

    context "with extra params" do
      let(:new_form_params) { { name: "test form one", submission_email: "test@example.gov.uk", support_url: "http://example.org" } }

      it "returns a status code 201" do
        expect(response).to have_http_status(:created)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to include(id: created_form[:id], **new_form_params)
      end

      it "created the form in the DB" do
        expect(created_form[:name]).to eq("test form one")
        expect(created_form[:submission_email]).to eq("test@example.gov.uk")
        expect(created_form[:support_url]).to eq("http://example.org")
      end
    end

    context "with created_at and updated_at params" do
      let(:new_form_params) { { name: "test form one", submission_email: "test@example.gov.uk", created_at: "2023-01-11T16:22:22.661+00:00", updated_at: "2023-01-11T16:24:22.661+00:00" } }

      it "does not use the provided created_at or updated_at values" do
        expect(response).to have_http_status(:created)
        expect(created_form[:created_at]).to eq(Time.current)
        expect(created_form[:updated_at]).to eq(Time.current)
      end
    end
  end

  describe "#show" do
    it "when no forms exists for an id, returns 404 and an empty json array" do
      get form_path(id: 987), as: :json
      expect(response).to have_http_status(:not_found)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq(error: "not_found")
    end

    # This test is for documenting Grape API only
    it "when given an invalid id, returns 500 and an empty json array" do
      get form_path(id: "invalid_id"), as: :json
      expect(response).to have_http_status(:not_found)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq(error: "not_found")
    end

    it "when given an existing id, returns 200 and form data" do
      form1 = Form.create!(name: "test form 1", creator_id: 123)
      get form_path(form1), as: :json
      expect(response).to have_http_status(:ok)
      expect(response.headers["Content-Type"]).to eq("application/json")

      expect(json_body).to match(
        id: form1.id,
        name: "test form 1",
        submission_email: nil,
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
        created_at: form1.created_at.as_json,
        updated_at: form1.updated_at.as_json,
        has_routing_errors: false,
        incomplete_tasks: %w[missing_pages missing_what_happens_next missing_privacy_policy_url missing_contact_details],
        ready_for_live: false,
        task_statuses: { declaration_status: "not_started", make_live_status: "cannot_start", name_status: "completed", pages_status: "not_started", privacy_policy_status: "not_started", support_contact_details_status: "not_started", what_happens_next_status: "not_started", payment_link_status: "optional" },
        state: "draft",
        payment_url: nil,
      )
    end
  end

  describe "#update" do
    let(:form) { create :form }

    it "when no forms exists for an id, returns 404 an error" do
      put form_path(id: 999), as: :json
      expect(response).to have_http_status(:not_found)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq(error: "not_found")
    end

    it "when given an valid id and params, updates DB and returns 200" do
      put form_path(form), params: { submission_email: "test@example.gov.uk" }, as: :json
      expect(response).to have_http_status(:ok)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to include(submission_email: "test@example.gov.uk")
      expect(form.reload.submission_email).to eq("test@example.gov.uk")
    end

    it "ignores created_at" do
      expect { put form_path(form), params: { created_at: "2023-01-11T16:22:22.661+00:00" }, as: :json }.not_to(change { form.reload.created_at })
    end

    it "ignores updated_at" do
      expect { put form_path(form), params: { updated_at: "2023-01-11T16:22:22.661+00:00" }, as: :json }.not_to(change { form.reload.updated_at })
    end

    context "when form is live" do
      let(:form) { create(:form, :live) }

      it "updates form state to live_with_draft" do
        put form_path(form), params: { submission_email: "test@example.gov.uk" }, as: :json
        expect(form.reload.state).to eq("live_with_draft")
      end
    end

    context "when form is archived" do
      let(:form) { create(:form, :archived) }

      it "updates form state to archived_with_draft" do
        put form_path(form), params: { submission_email: "test@example.gov.uk" }, as: :json
        expect(form.reload.state).to eq("archived_with_draft")
      end
    end
  end

  describe "#destroy" do
    it "when no forms exists for an id, returns 404 an error" do
      delete form_path(123), as: :json
      expect(response).to have_http_status(:not_found)
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
        expect(response).to have_http_status(:forbidden)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to eq(%w[missing_pages missing_what_happens_next missing_privacy_policy_url missing_contact_details])
      end
    end

    it "when given a form, sets live_at to current time" do
      form_to_be_made_live = create(:form, :ready_for_live)
      post make_live_form_path(form_to_be_made_live), as: :json
      expect(response).to have_http_status(:ok)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to include(live_at: Time.zone.now)
    end
  end

  describe "#show_live" do
    it "returns the actual made live version which includes pages" do
      made_live_form = create :made_live_form
      made_live_form.form.update!(name: "Updated form")

      get live_form_path(made_live_form.form), as: :json

      expect(response).to have_http_status(:ok)
      expect(response.headers["Content-Type"]).to eq("application/json")

      expect(json_body.to_json).to eq made_live_form.json_form_blob
    end

    it "returns 404 if form has never existed" do
      get live_form_path(1), as: :json

      expect(response).to have_http_status(:not_found)
      expect(response.headers["Content-Type"]).to eq("application/json")
    end

    it "returns 404 if form is not live" do
      form = create :form
      get live_form_path(form.id), as: :json

      expect(response).to have_http_status(:not_found)
      expect(response.headers["Content-Type"]).to eq("application/json")
    end
  end

  describe "#show_draft" do
    it "returns the draft version which includes pages" do
      draft_form = create :form, :ready_for_live

      get draft_form_path(draft_form), as: :json

      expect(response).to have_http_status(:ok)
      expect(response.headers["Content-Type"]).to eq("application/json")

      expect(json_body.to_json).to eq draft_form.snapshot.to_json
    end

    it "returns 404 if draft form doesn't exist" do
      get draft_form_path(1), as: :json

      expect(response).to have_http_status(:not_found)
      expect(response.headers["Content-Type"]).to eq("application/json")
    end
  end

  describe "#archive" do
    it "when no forms exists for an id, returns 404 an error" do
      post archive_form_path(123), as: :json
      expect(response).to have_http_status(:not_found)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq(error: "not_found")
    end

    it "when the from is not in an archivable state" do
      form = create(:form)
      post archive_form_path(form), as: :json

      expect(response).to have_http_status(:forbidden)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(json_body).to eq(error: "Form cannot be archived")
    end

    context "when the form is live" do
      it "archives the form" do
        form = create(:made_live_form).form
        post archive_form_path(form), as: :json

        expect(response).to have_http_status(:ok)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to include(state: "archived")
      end
    end

    context "when the form is live with draft" do
      it "archives the form with draft" do
        form = create(:made_live_form).form
        form.create_draft_from_live_form!
        post archive_form_path(form), as: :json

        expect(response).to have_http_status(:ok)
        expect(response.headers["Content-Type"]).to eq("application/json")
        expect(json_body).to include(state: "archived_with_draft")
      end
    end
  end

  describe "#show_archived" do
    it "returns the last made live version" do
      made_live_form = create :made_live_form
      made_live_form.form.archive_live_form!

      get archived_form_path(made_live_form.form), as: :json

      expect(response).to have_http_status(:ok)
      expect(response.headers["Content-Type"]).to eq("application/json")

      expect(json_body.to_json).to eq made_live_form.json_form_blob
    end

    it "returns 404 if form has never existed" do
      get archived_form_path(1), as: :json

      expect(response).to have_http_status(:not_found)
      expect(response.headers["Content-Type"]).to eq("application/json")
    end
  end
end

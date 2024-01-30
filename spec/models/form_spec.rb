require "rails_helper"

RSpec.describe Form, type: :model do
  subject(:form) { described_class.new }

  it "has a valid factory" do
    form = create :form
    expect(form).to be_valid
  end

  describe "versioning", versioning: true do
    it "enables paper trail" do
      expect(form).to be_versioned
    end
  end

  describe ".destroy" do
    context "when a form was made live" do
      let(:made_live_form) { create :made_live_form }
      let(:form) { made_live_form.form }

      it "does delete a live form" do
        expect { form.destroy }.to change { MadeLiveForm.exists?(made_live_form.id) }.to(false)
      end
    end
  end

  describe "validations" do
    it "validates" do
      form.name = "test"
      expect(form).to be_valid
    end

    it "requires name" do
      expect(form).to be_invalid
      expect(form.errors[:name]).to include("can't be blank")
    end

    context "when the form has validation errors" do
      let(:form) { create :form, pages: [routing_page, goto_page] }
      let(:routing_page) do
        new_routing_page = create :page
        new_routing_page.routing_conditions = [(create :condition, routing_page_id: new_routing_page.id, goto_page_id: nil)]
        new_routing_page
      end
      let(:goto_page) { create :page }
      let(:goto_page_id) { goto_page.id }

      context "when the form is marked complete" do
        it "returns invalid" do
          form.question_section_completed = true

          expect(form).to be_invalid
          expect(form.errors[:base]).to include("Form has routing validation errors")
        end
      end

      context "when the form is not marked complete" do
        it "returns valid" do
          form.question_section_completed = false
          expect(form).to be_valid
        end
      end
    end
  end

  describe "form_slug" do
    it "updates when name is changed" do
      form.name = "Apply for a license to test forms"
      expect(form.name).to eq("Apply for a license to test forms")
      expect(form.form_slug).to eq("apply-for-a-license-to-test-forms")
    end

    it "setting form slug directly doesn't change it" do
      form.name = "Apply for a license to test forms"
      form.form_slug = "something totally different"
      expect(form.form_slug).to eq("apply-for-a-license-to-test-forms")
    end
  end

  describe "start_page" do
    it "returns nil when form has no pages" do
      expect(form.start_page).to be_nil
    end

    it "returns first page id based on position" do
      form = build :form, :with_pages
      expect(form.start_page).to eq(form.pages.first.id)
    end
  end

  describe "page scope" do
    it "returns pages in position order" do
      form = create :form

      page_a = create :page, form_id: form.id, position: 2
      page_b = create :page, form_id: form.id, position: 1

      expect(form.pages).to eq([page_b, page_a])
    end
  end

  describe "scopes" do
    let(:form_a) { create :form, organisation_id: 111 }
    let(:form_b) { create :form, creator_id: 123, organisation_id: 111 }
    let(:form_c) { create :form, creator_id: 1234 }

    it "return forms with matching creator ID" do
      expect(described_class.filter_by_creator_id(1234)).to eq([form_c])
    end

    it "return forms with matching organisation" do
      expect(described_class.filter_by_organisation_id(111)).to eq([form_a, form_b])
    end

    it "return forms with matching organisation and creator ID" do
      described_class.filter_by_organisation_id(111)
      forms = described_class.filter_by_creator_id(123)
      expect(forms).to eq([form_b])
    end
  end

  describe "#make_live! from FormStateMachine" do
    let(:form_to_be_made_live) { create :form, :ready_for_live }
    let(:time_now) { Time.zone.now }

    before do
      freeze_time do
        time_now
        form_to_be_made_live.make_live!
      end
    end

    it "sets a forms live_at to make the form live" do
      expect(form_to_be_made_live.live_at).to eq(time_now)
    end

    it "creates a made live version" do
      expect(form_to_be_made_live.made_live_forms.last.json_form_blob)
        .to eq(form_to_be_made_live.snapshot(live_at: time_now).to_json)
    end

    it "the made live version has a live_at datetime" do
      form_blob = JSON.parse(
        form_to_be_made_live.made_live_forms.last.json_form_blob,
        symbolize_names: true,
      )

      expect(Time.zone.parse(form_blob[:live_at])).to eq time_now
    end

    it "makes timestamps consistent" do
      form = create :form, :ready_for_live
      form.make_live!
      made_live_form = form.made_live_forms.last

      expect(form.live_at).to eq(made_live_form.created_at)
      expect(form.updated_at).to eq(made_live_form.created_at)
    end
  end

  describe ".make_unlive!" do
    let(:made_live_form) { create :made_live_form }
    let(:form) { made_live_form.form }

    it "deletes the made live version" do
      expect { form.make_unlive! }.to change { MadeLiveForm.exists?(made_live_form.id) }.to(false)
    end

    it "sets the live_at to nil" do
      form.make_unlive!
      expect(form.live_at).to be_nil
    end
  end

  describe "#has_draft_version" do
    let(:live_form) { create(:made_live_form).form }
    let(:new_form) { create(:form) }

    it "returns true if form is draft" do
      new_form.state = :draft
      expect(new_form.has_draft_version).to eq(true)
    end

    it "returns false if form is live and no edits" do
      live_form.state = :live
      expect(live_form.has_draft_version).to eq(false)
    end

    it "returns true if form is live with a draft" do
      live_form.state = :live_with_draft
      live_form.update!(name: "Form (edited)")

      expect(live_form.has_draft_version).to eq(true)
    end

    it "returns true if form has been made live and one of its pages has been edited" do
      live_form.pages[0].question_text = "Edited question"
      live_form.pages[0].save_and_update_form

      expect(live_form.has_draft_version).to eq(true)
    end
  end

  describe "#live_at" do
    it "returns nil if form has not been made live" do
      form = create :form
      expect(form.live_at).to be_nil
    end
  end

  describe "#has_live_version" do
    let(:live_form) { create(:made_live_form).form }
    let(:new_form) { create(:form) }

    it "returns false if form has not been made live before" do
      expect(new_form.has_live_version).to eq(false)
    end

    it "returns true if form has been made live" do
      expect(live_form.has_live_version).to eq(true)
    end
  end

  describe "#live_version" do
    let(:made_live_form) { create :made_live_form }

    it "returns json version of the LIVE form and includes pages" do
      expect(made_live_form.form.live_version).to eq(made_live_form.form.snapshot.to_json)
    end
  end

  describe "#snapshot" do
    let(:snapshot) { create(:form).snapshot }

    it "creates a version of a form with its pages" do
      expect(snapshot.keys).to contain_exactly(
        "id",
        "name",
        "submission_email",
        "organisation_id",
        "creator_id",
        "created_at",
        "updated_at",
        "privacy_policy_url",
        "form_slug",
        "start_page",
        "support_email",
        "support_phone",
        "support_url",
        "support_url_text",
        "declaration_text",
        "question_section_completed",
        "declaration_section_completed",
        "pages",
        "page_order",
        "what_happens_next_markdown",
      )
    end
  end

  describe "#has_routing_errors" do
    let(:form) { create :form, pages: [routing_page, goto_page] }
    let(:routing_page) do
      new_routing_page = create :page
      new_routing_page.routing_conditions = [(create :condition, routing_page_id: new_routing_page.id, goto_page_id:)]
      new_routing_page
    end
    let(:goto_page) { create :page }
    let(:goto_page_id) { goto_page.id }

    context "when there are no validation errors" do
      it "returns false" do
        expect(form.has_routing_errors).to be false
      end
    end

    context "when there are validation errors" do
      let(:goto_page_id) { nil }

      it "returns true" do
        expect(form.has_routing_errors).to be true
      end
    end
  end

  describe "#ready_for_live" do
    context "when a form is complete and ready to be made live" do
      let(:completed_form) { create(:form, :live) }

      it "returns true" do
        expect(completed_form.ready_for_live).to eq true
      end
    end

    context "when a form is incomplete and should still be in draft state" do
      let(:new_form) { build :form, :new_form }

      [
        {
          attribute: :pages,
          attribute_value: [],
        },
        {
          attribute: :what_happens_next_markdown,
          attribute_value: nil,
        },
        {
          attribute: :privacy_policy_url,
          attribute_value: nil,
        },
        {
          attribute: :support_email,
          attribute_value: nil,
        },
      ].each do |scenario|
        it "returns false if #{scenario[:attribute]} is missing" do
          new_form.send("#{scenario[:attribute]}=", scenario[:attribute_value])
          expect(new_form.ready_for_live).to eq false
        end
      end
    end
  end

  describe "#incomplete_tasks" do
    context "when a form is complete and ready to be made live" do
      let(:completed_form) { build :form, :live }

      it "returns no missing sections" do
        expect(completed_form.incomplete_tasks).to be_empty
      end
    end

    context "when a form is incomplete and should still be in draft state" do
      let(:new_form) { build :form, :new_form }

      it "returns a set of keys related to missing fields" do
        expect(new_form.incomplete_tasks).to match_array(%i[missing_pages missing_privacy_policy_url missing_contact_details missing_what_happens_next])
      end
    end
  end

  describe "#task_statuses" do
    let(:completed_form) { create(:form, :live) }

    it "returns a hash with each of the task statuses" do
      expected_hash = {
        name_status: :completed,
        pages_status: :completed,
        declaration_status: :completed,
        what_happens_next_status: :completed,
        privacy_policy_status: :completed,
        support_contact_details_status: :completed,
        make_live_status: :completed,
      }
      expect(completed_form.task_statuses).to eq expected_hash
    end
  end
end

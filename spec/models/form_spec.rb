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

  describe "made_live_form" do
    let(:made_live_form) { create :made_live_form }
    let(:form) { made_live_form.form }

    it "does delete a live form" do
      expect { form.destroy }.to change { MadeLiveForm.exists?(made_live_form.id) }.to(false)
    end
  end

  describe "validations" do
    it "validates" do
      form.name = "test"
      form.org = "test-org"
      expect(form).to be_valid
    end

    it "requires name" do
      expect(form).to be_invalid
      expect(form.errors[:name]).to include("can't be blank")
    end

    it "requires org" do
      expect(form).to be_invalid
      expect(form.errors[:org]).to include("can't be blank")
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

  describe "#make_live!" do
    let(:form_to_be_made_live) { build :form }
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

    it "does create a made live version" do
      expect(form_to_be_made_live.made_live_forms.last.json_form_blob).to eq form_to_be_made_live.to_json(include: [:pages])
    end
  end

  describe "#live_version" do
    let(:made_live_form) { create :made_live_form }

    it "returns json version of the LIVE form and includes pages" do
      expect(made_live_form.form.live_version).to eq(made_live_form.form.to_json(include: [:pages]))
    end

    context "when a form has never been made live before" do
      let(:form) { create :form, :ready_for_live }

      it "returns the draft version of the form" do
        expect(form.live_version).to eq(form.to_json(include: [:pages]))
      end
    end
  end
end

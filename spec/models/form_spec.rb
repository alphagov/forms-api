require "rails_helper"

RSpec.describe Form, type: :model do
  subject(:form) { described_class.new }

  it "has a valid factory" do
    form = create :form
    expect(form).to be_valid
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
end

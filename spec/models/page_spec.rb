require "rails_helper"

RSpec.describe Page, type: :model do
  subject(:page) { described_class.new }

  it "has a valid factory" do
    page = create :page
    expect(page).to be_valid
  end

  describe "versioning", versioning: true do
    it "enables paper trail" do
      expect(page).to be_versioned
    end
  end

  describe "validations" do
    it "validates" do
      form = create :form
      page.form_id = form.id
      page.question_text = "Example question"
      page.answer_type = "national_insurance_number"
      expect(page).to be_valid
    end

    it "requires question_text" do
      expect(page).to be_invalid
      expect(page.errors[:question_text]).to include("can't be blank")
    end

    it "requires form" do
      expect(page).to be_invalid
      expect(page.errors[:form]).to include("must exist")
    end

    it "requires answer_type" do
      expect(page).to be_invalid
      expect(page.errors[:answer_type]).to include("can't be blank")
    end

    it "requires answer_type to be in list" do
      page.answer_type = "unknown_type"
      expect(page).to be_invalid
      expect(page.errors[:answer_type]).to include("is not included in the list")
    end
  end

  describe "#destroy_and_update_form!" do
    let(:page) { create :page }
    let(:form) { page.form }

    it "sets form.question_section_completed to false" do
      form.update!(question_section_completed: true)

      page.destroy_and_update_form!
      expect(form.question_section_completed).to be false
    end
  end

  describe "#save_and_update_form" do
    let(:page) { create :page }
    let(:form) { page.form }

    it "sets form.question_section_completed to false" do
      form.update!(question_section_completed: true)

      page.question_text = "Edited question"
      page.save_and_update_form
      expect(form.question_section_completed).to be false
    end
  end
end

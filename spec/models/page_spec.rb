require "rails_helper"

RSpec.describe Page, type: :model do
  subject(:page) { described_class.new }

  it "has a valid factory" do
    page = create :page
    expect(page).to be_valid
  end

  describe "validations" do
    it "validates" do
      form = create :form
      page.form_id = form.id
      page.question_text = "Example question"
      page.answer_type = "single_line"
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
end

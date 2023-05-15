require "rails_helper"

RSpec.describe Page, type: :model do
  subject(:page) { create :page, :with_selections_settings, form:, routing_conditions: }

  let(:form) { create :form }
  let(:routing_conditions) { [] }

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
      page.question_text = "Example question"
      page.answer_type = "national_insurance_number"
      expect(page).to be_valid
    end

    it "requires question_text" do
      page.question_text = nil
      expect(page).to be_invalid
      expect(page.errors[:question_text]).to include("can't be blank")
    end

    it "requires form" do
      page.form_id = nil
      expect(page).to be_invalid
      expect(page.errors[:form]).to include("must exist")
    end

    it "requires answer_type" do
      page.answer_type = nil
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
    it "sets form.question_section_completed to false" do
      page.question_text = "Edited question"
      page.save_and_update_form
      expect(form.question_section_completed).to be false
    end

    context "when page has routing conditions" do
      let(:routing_conditions) { [(create :condition)] }

      it "does not delete existing conditions" do
        page.save_and_update_form
        expect(page.reload.routing_conditions.to_a).to eq(routing_conditions)
      end

      context "when answer type is updated to one doesn't support routing" do
        it "deletes any conditions" do
          page.answer_type = "number"
          page.save_and_update_form
          expect(page.reload.routing_conditions).to be_empty
        end
      end
    end
  end
end

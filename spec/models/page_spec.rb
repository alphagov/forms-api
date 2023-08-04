require "rails_helper"

RSpec.describe Page, type: :model do
  subject(:page) { create :page, :with_selections_settings, form:, routing_conditions:, check_conditions: }

  let(:form) { create :form }
  let(:routing_conditions) { [] }
  let(:check_conditions) { [] }

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

    context "when additional_guidance_fields are provided" do
      it "requires additional_guidance_markdown if page_heading is present" do
        page.page_heading = "My new page heading"
        expect(page).to be_invalid
        expect(page.errors[:additional_guidance_markdown]).to include("must be present when Page Heading is present")
      end

      it "requires page_heading if additional_guidance_markdown is present" do
        page.additional_guidance_markdown = "Some extra guidance for this question"
        expect(page).to be_invalid
        expect(page.errors[:page_heading]).to include("must be present when Additional Guidance Markdown is present")
      end
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
      let(:check_conditions) { routing_conditions }

      it "does not delete existing conditions" do
        page.save_and_update_form
        expect(page.reload.routing_conditions.to_a).to eq(routing_conditions)
        expect(page.reload.check_conditions.to_a).to eq(check_conditions)
      end

      context "when answer type is updated to one doesn't support routing" do
        it "deletes any conditions" do
          page.answer_type = "number"
          page.save_and_update_form
          expect(page.reload.check_conditions).to be_empty
        end
      end

      context "when the page is saved without changing the answer type" do
        it "does not delete the conditions" do
          page.question_text = "test"
          page.save_and_update_form
          expect(page.reload.check_conditions).not_to be_empty
        end
      end

      context "when the answer settings no longer restrict to only one option" do
        it "deletes any conditions" do
          page.answer_settings["only_one_option"] = "0"
          page.save_and_update_form
          expect(page.reload.check_conditions).to be_empty
        end
      end

      context "when the answer settings change while still restricting to only one option" do
        it "does not delete any conditions" do
          page.answer_settings["selection_options"].first["name"] = "New option name"
          page.save_and_update_form
          expect(page.reload.check_conditions).not_to be_empty
        end
      end
    end
  end

  describe "#has_routing_errors" do
    let(:routing_page) { create :page, form: }
    let(:goto_page) { create :page, form: }
    let(:goto_page_id) { goto_page.id }
    let(:routing_conditions) { [condition] }
    let(:condition) { create :condition, routing_page_id: routing_page.id, goto_page_id: }

    context "when there are no validation errors" do
      it "returns false" do
        expect(page.has_routing_errors).to be false
      end
    end

    context "when there are validation errors" do
      let(:goto_page_id) { nil }

      it "returns true" do
        expect(page.has_routing_errors).to be true
      end
    end
  end
end

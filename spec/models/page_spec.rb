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

    describe "#question_text" do
      let(:page) { build :page, question_text: }
      let(:question_text) { "What is your address?" }

      it "is required" do
        page.question_text = nil
        expect(page).to be_invalid
        expect(page.errors[:question_text]).to include(I18n.t("activerecord.errors.models.page.attributes.question_text.blank"))
      end

      it "is valid if question text below 250 characters" do
        expect(page).to be_valid
      end

      context "when question text 250 characters" do
        let(:question_text) { "A" * 250 }

        it "is valid" do
          expect(page).to be_valid
        end
      end

      context "when question text more 250 characters" do
        let(:question_text) { "A" * 251 }

        it "is invalid" do
          expect(page).not_to be_valid
        end

        it "has an error message" do
          page.valid?
          expect(page.errors[:question_text]).to include(I18n.t("activerecord.errors.models.page.attributes.question_text.too_long", count: 250))
        end
      end
    end

    describe "#hint_text" do
      let(:page) { build :page, hint_text: }
      let(:hint_text) { "Enter your full name as it appears in your passport" }

      it "is valid if hint text is empty" do
        page.hint_text = nil
        expect(page).to be_valid
      end

      it "is valid if hint text below 500 characters" do
        expect(page).to be_valid
      end

      context "when hint text 500 characters" do
        let(:hint_text) { "A" * 500 }

        it "is valid" do
          expect(page).to be_valid
        end
      end

      context "when hint text more than 500 characters" do
        let(:hint_text) { "A" * 501 }

        it "is invalid" do
          expect(page).not_to be_valid
        end

        it "has an error message" do
          page.valid?
          expect(page.errors[:hint_text]).to include(I18n.t("activerecord.errors.models.page.attributes.hint_text.too_long", count: 500))
        end
      end
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

    context "when guidance_fields are provided" do
      it "requires guidance_markdown if page_heading is present" do
        page.page_heading = "My new page heading"
        expect(page).to be_invalid
        expect(page.errors[:guidance_markdown]).to include("must be present when Page Heading is present")
      end

      it "requires page_heading if guidance_markdown is present" do
        page.guidance_markdown = "Some extra guidance for this question"
        expect(page).to be_invalid
        expect(page.errors[:page_heading]).to include("must be present when Guidance Markdown is present")
      end

      describe "page_heading length validations" do
        let(:page) { build :page, :with_guidance, page_heading: }
        let(:page_heading) { "What is your address?" }

        it "is valid if page heading below 500 characters" do
          expect(page).to be_valid
        end

        context "when page heading 250 characters" do
          let(:page_heading) { "A" * 250 }

          it "is valid" do
            expect(page).to be_valid
          end
        end

        context "when page_heading more than 250 characters" do
          let(:page_heading) { "A" * 251 }

          it "is invalid" do
            expect(page).not_to be_valid
          end

          it "has an error message" do
            page.valid?
            expect(page.errors[:page_heading]).to include(I18n.t("activerecord.errors.models.page.attributes.page_heading.too_long", count: 250))
          end
        end
      end

      context "when markdown is too long" do
        it "adds an error to guidance_markdown" do
          page.guidance_markdown = "ABC" * 5000
          expect(page).to be_invalid
          expect(page.errors[:guidance_markdown]).to include("is too long (maximum is 4999 characters)")
        end
      end

      context "when markdown is using unsupported syntax" do
        it "adds error to guidance_markdown" do
          page.guidance_markdown = "# Heading level 1"
          expect(page).to be_invalid
          expect(page.errors[:guidance_markdown]).to include("can only contain formatting for links, subheadings(##), bulleted listed (*), or numbered lists(1.)")
        end
      end

      context "when markdown is using unsupported syntax which is too long" do
        it "adds error to guidance_markdown" do
          page.guidance_markdown = "# Heading level 1\n\n" * 5000
          expect(page).to be_invalid
          expect(page.errors[:guidance_markdown]).to include("can only contain formatting for links, subheadings(##), bulleted listed (*), or numbered lists(1.)")
          expect(page.errors[:guidance_markdown]).to include("is too long (maximum is 4999 characters)")
        end
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

    context "when the form is live" do
      let(:form) { create(:form, :live) }

      it "updates the form state to live_with_draft" do
        page.question_text = "Edited question"
        page.save_and_update_form
        expect(form.state).to eq("live_with_draft")
      end
    end

    context "when the form is archived" do
      let(:form) { create(:form, :archived) }

      it "updates the form state to archived_with_draft" do
        page.question_text = "Edited question"
        page.save_and_update_form
        expect(form.state).to eq("archived_with_draft")
      end
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

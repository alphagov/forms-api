require "rails_helper"

RSpec.describe Condition, type: :model do
  subject(:condition) { described_class.new }

  it "has a valid factory" do
    condition = create :condition
    expect(condition).to be_valid
  end

  describe "versioning", :versioning do
    it "enables paper trail" do
      expect(condition).to be_versioned
    end
  end

  describe "validations" do
    it "validates" do
      page = create :page
      condition.routing_page_id = page.id
      expect(condition).to be_valid
    end

    it "requires routing_page_id" do
      expect(condition).to be_invalid
      expect(condition.errors[:routing_page]).to include("must exist")
    end
  end

  describe "#validation_errors" do
    let(:form) { create :form }
    let(:routing_page) { create :page, form: }
    let(:goto_page) { nil }
    let(:condition) { create :condition, routing_page_id: routing_page.id, goto_page_id: nil }

    it "returns array of validation error objects" do
      expect(condition.validation_errors).to eq([{ name: "goto_page_doesnt_exist" }])
    end

    it "calls each validation method" do
      %i[warning_goto_page_doesnt_exist
         warning_answer_doesnt_exist
         warning_routing_to_next_page
         warning_goto_page_before_check_page ].each do |validation_methods|
        expect(condition).to receive(validation_methods)
      end
      condition.validation_errors
    end

    it "calls warning_goto_page_doesnt_exist" do
      expect(condition).to receive(:warning_goto_page_doesnt_exist)
      condition.validation_errors
    end

    context "when no validation errors" do
      let(:goto_page) { create :page, form: }
      let(:condition) { create :condition, routing_page_id: routing_page.id, goto_page_id: goto_page.id }

      it "returns empty array if there are no validation errors" do
        expect(condition.validation_errors).to be_empty
      end
    end
  end

  describe "#warning_goto_page_doesnt_exist" do
    let(:form) { create :form }
    let(:routing_page) { create :page, form: }
    let(:goto_page) { create :page, form: }
    let(:condition) { create :condition, routing_page_id: routing_page.id, goto_page_id: goto_page.id }

    it "returns nil if goto page exists" do
      expect(condition.warning_goto_page_doesnt_exist).to be_nil
    end

    context "when goto page is null and skip_to_end is true" do
      let(:condition) { create :condition, routing_page_id: routing_page.id, goto_page_id: nil, skip_to_end: true }

      it "returns nil" do
        expect(condition.warning_goto_page_doesnt_exist).to be_nil
      end
    end

    context "when goto page has been deleted" do
      let(:condition) { create :condition, routing_page_id: routing_page.id, goto_page_id: 999 }

      it "returns object with error short name code" do
        expect(condition.warning_goto_page_doesnt_exist).to eq({ name: "goto_page_doesnt_exist" })
      end
    end

    context "when goto page may belong to another form" do
      let(:goto_page) { create :page }

      it "returns object with error short name code" do
        expect(condition.warning_goto_page_doesnt_exist).to eq({ name: "goto_page_doesnt_exist" })
      end
    end
  end

  describe "#warning_answer_doesnt_exist" do
    let(:form) { create :form }
    let(:check_page) { create :page, :with_selections_settings, form: }
    let(:goto_page) { create :page, form: }
    let(:condition) do
      new_condition = create :condition, routing_page_id: check_page.id, check_page_id: check_page.id, goto_page_id: goto_page.id
      new_condition.answer_value = check_page.answer_settings["selection_options"].first["name"]
      new_condition
    end

    it "returns nil if answer exists" do
      expect(condition.warning_answer_doesnt_exist).to be_nil
    end

    context "when answer has been deleted from page" do
      it "returns object with error short name code" do
        condition.check_page.answer_settings["selection_options"].shift
        expect(condition.warning_answer_doesnt_exist).to eq({ name: "answer_value_doesnt_exist" })
      end
    end

    context "when answer on the page has been updated" do
      it "returns object with error short name code" do
        condition.check_page.answer_settings["selection_options"].first["name"] = "Option 1.2"
        expect(condition.warning_answer_doesnt_exist).to eq({ name: "answer_value_doesnt_exist" })
      end
    end

    context "when answer_value is 'None of the above" do
      let(:condition) { create :condition, routing_page_id: check_page.id, check_page_id: check_page.id, goto_page_id: goto_page.id, answer_value: :none_of_the_above.to_s }
      let(:check_page) { create :page, :with_selections_settings, form:, is_optional: }

      context "and routing page has 'None of the above' as an option" do
        let(:is_optional) { true }

        it "returns nil" do
          expect(condition.warning_answer_doesnt_exist).to eq(nil)
        end
      end

      context "and routing page does not have 'None of the above' as an option" do
        let(:is_optional) { false }

        it "returns object with error short name code" do
          expect(condition.warning_answer_doesnt_exist).to eq({ name: "answer_value_doesnt_exist" })
        end
      end
    end
  end

  describe "#warning_routing_to_next_page" do
    let(:form) { create :form }
    let(:current_page) { create :page, form: }
    let(:next_page) { create :page, form: }
    let(:last_page) { create :page, form: }
    let(:condition) { create :condition, routing_page_id: current_page.id, check_page_id: current_page.id, goto_page_id: last_page.id }

    before do
      current_page
      next_page
      last_page
    end

    it "returns nil if go to page is not the next page" do
      expect(condition.warning_routing_to_next_page).to be_nil
    end

    context "when goto page is the next page" do
      let(:condition) { create :condition, routing_page_id: current_page.id, check_page_id: current_page.id, goto_page_id: next_page.id }

      it "returns object with error short name code" do
        expect(condition.warning_routing_to_next_page).to eq({ name: "cannot_route_to_next_page" })
      end
    end

    context "when goto page nil" do
      let(:condition) { create :condition, routing_page_id: current_page.id, check_page_id: current_page.id, goto_page_id: nil }

      it "returns nil" do
        expect(condition.warning_routing_to_next_page).to be_nil
      end
    end

    context "when check page nil" do
      let(:condition) { create :condition, routing_page_id: current_page.id, check_page_id: nil, goto_page_id: next_page.id }

      it "returns nil" do
        expect(condition.warning_routing_to_next_page).to be_nil
      end
    end

    context "when goto page is nil and skip_to_end is true" do
      context "when the routing_page is at the end of the form" do
        let(:condition) { create :condition, routing_page_id: last_page.id, check_page_id: last_page.id, goto_page_id: nil, skip_to_end: true }

        it "returns object with error short name code" do
          expect(condition.warning_routing_to_next_page).to eq({ name: "cannot_route_to_next_page" })
        end
      end

      context "when the routing_page is not at the end of the form" do
        let(:condition) { create :condition, routing_page_id: current_page.id, check_page_id: current_page.id, goto_page_id: nil, skip_to_end: false }

        it "returns nil" do
          expect(condition.warning_routing_to_next_page).to be_nil
        end
      end
    end
  end

  describe "#warning_goto_page_before_check_page" do
    let(:form) { create :form }
    let(:previous_page) { create :page, form: }
    let(:current_page) { create :page, form: }
    let(:next_page) { create :page, form: }
    let(:last_page) { create :page, form: }
    let(:condition) { create :condition, routing_page_id: current_page.id, check_page_id: current_page.id, goto_page_id: last_page.id }

    before do
      previous_page
      current_page
      next_page
      last_page
    end

    it "returns nil if go to page is not before the check next page" do
      expect(condition.warning_goto_page_before_check_page).to be_nil
    end

    context "when goto page is before the check page" do
      let(:condition) { create :condition, routing_page_id: current_page.id, check_page_id: current_page.id, goto_page_id: previous_page.id }

      it "returns object with error short name code" do
        expect(condition.warning_goto_page_before_check_page).to eq({ name: "cannot_have_goto_page_before_routing_page" })
      end
    end

    context "when goto page is nil and skip_to_end is false" do
      let(:condition) { create :condition, routing_page_id: current_page.id, check_page_id: current_page.id, goto_page_id: nil, skip_to_end: false }

      it "returns nil" do
        expect(condition.warning_goto_page_before_check_page).to be_nil
      end
    end

    context "when goto page is nil and skip_to_end is true" do
      let(:condition) { create :condition, routing_page_id: current_page.id, check_page_id: current_page.id, goto_page_id: nil, skip_to_end: true }

      it "returns nil" do
        expect(condition.warning_goto_page_before_check_page).to be_nil
      end
    end

    context "when check page nil" do
      let(:condition) { create :condition, routing_page_id: current_page.id, check_page_id: nil, goto_page_id: next_page.id }

      it "returns nil" do
        expect(condition.warning_goto_page_before_check_page).to be_nil
      end
    end
  end

  describe "#is_check_your_answers?" do
    let(:form) { create :form }
    let(:check_page) { create :page, :with_selections_settings, form: }
    let(:goto_page) { create :page, form: }

    context "when goto page is nil and skip_to_end is false" do
      let(:condition) { create :condition, routing_page_id: check_page.id, check_page_id: check_page.id, goto_page_id: nil, skip_to_end: false }

      it "returns nil" do
        expect(condition.is_check_your_answers?).to be false
      end
    end

    context "when goto page is nil and skip_to_end is true" do
      let(:condition) { create :condition, routing_page_id: check_page.id, check_page_id: check_page.id, goto_page_id: nil, skip_to_end: true }

      it "returns nil" do
        expect(condition.is_check_your_answers?).to be true
      end
    end

    context "when goto page has a value and skip_to_end is false" do
      let(:condition) { create :condition, routing_page_id: check_page.id, check_page_id: check_page.id, goto_page_id: goto_page.id, skip_to_end: false }

      it "returns nil" do
        expect(condition.is_check_your_answers?).to be false
      end
    end

    context "when goto page has a value and skip_to_end is true" do
      let(:condition) { create :condition, routing_page_id: check_page.id, check_page_id: check_page.id, goto_page_id: goto_page.id, skip_to_end: true }

      it "returns nil" do
        expect(condition.is_check_your_answers?).to be false
      end
    end
  end

  describe "#has_routing_errors" do
    let(:form) { create :form }
    let(:goto_page) { create :page, form: }
    let(:goto_page_id) { goto_page.id }
    let(:routing_page) { create :page, form: }
    let(:condition) { create :condition, routing_page_id: routing_page.id, goto_page_id: }

    context "when there are no validation errors" do
      it "returns false" do
        expect(condition.has_routing_errors).to be false
      end
    end

    context "when there are validation errors" do
      let(:goto_page_id) { nil }

      it "returns true" do
        expect(condition.has_routing_errors).to be true
      end
    end
  end
end

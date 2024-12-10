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
      create(
        :condition,
        routing_page_id: check_page.id,
        check_page_id: check_page.id,
        goto_page_id: goto_page.id,
        answer_value: check_page.answer_settings["selection_options"].first["name"],
      )
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
          expect(condition.warning_answer_doesnt_exist).to be_nil
        end
      end

      context "and routing page does not have 'None of the above' as an option" do
        let(:is_optional) { false }

        it "returns object with error short name code" do
          expect(condition.warning_answer_doesnt_exist).to eq({ name: "answer_value_doesnt_exist" })
        end
      end
    end

    context "when condition is a after another condition for a branch route" do
      let(:routing_page) { create :page, form: }
      let(:after_condition) do
        create(
          :condition,
          answer_value: nil,
          check_page_id: condition.check_page_id,
          routing_page_id: routing_page.id,
          skip_to_end: true,
        )
      end

      it "returns nil" do
        expect(after_condition.warning_answer_doesnt_exist).to be_nil
      end
    end
  end

  describe "#warning_routing_to_next_page" do
    let(:form) { build :form, pages: [check_page, current_page, next_page, last_page] }
    let(:check_page) { build :page, position: 1 }
    let(:current_page) { build :page, position: 2 }
    let(:next_page) { build :page, position: 3 }
    let(:last_page) { build :page, position: 4 }

    shared_examples "returns no warning" do
      it "returns nil" do
        expect(condition.warning_routing_to_next_page).to be_nil
      end
    end

    shared_examples "returns routing warning" do
      it "returns cannot_route_to_next_page warning" do
        expect(condition.warning_routing_to_next_page).to eq({ name: "cannot_route_to_next_page" })
      end
    end

    context "when routing to a non-adjacent page" do
      let(:condition) do
        create :condition,
               routing_page: current_page,
               check_page: check_page,
               goto_page: last_page
      end

      it_behaves_like "returns no warning"
    end

    context "when routing to the next sequential page" do
      let(:condition) do
        create :condition,
               routing_page: current_page,
               check_page: check_page,
               goto_page: next_page
      end

      it_behaves_like "returns routing warning"
    end

    context "with nil values" do
      context "when goto_page is nil" do
        let(:condition) do
          create :condition,
                 routing_page: current_page,
                 check_page: check_page,
                 goto_page: nil
        end

        it_behaves_like "returns no warning"
      end

      context "when check_page is nil" do
        let(:condition) do
          create :condition,
                 routing_page: current_page,
                 check_page: nil,
                 goto_page: next_page
        end

        it_behaves_like "returns no warning"
      end
    end

    context "with skip_to_end functionality" do
      context "when routing from the last page" do
        let(:condition) do
          create :condition,
                 routing_page: last_page,
                 check_page: check_page,
                 goto_page: nil,
                 skip_to_end: true
        end

        it_behaves_like "returns routing warning"
      end

      context "when routing from a non-last page" do
        let(:condition) do
          create :condition,
                 routing_page: current_page,
                 check_page: check_page,
                 goto_page: nil,
                 skip_to_end: false
        end

        it_behaves_like "returns no warning"
      end
    end

    context "with non-sequential page positions" do
      let(:current_page) { build :page, position: 2 }
      let(:next_page) { build :page, position: 4 }
      let(:condition) do
        create :condition,
               routing_page: current_page,
               check_page: check_page,
               goto_page: next_page
      end

      it_behaves_like "returns no warning"
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

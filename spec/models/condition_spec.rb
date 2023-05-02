require "rails_helper"

RSpec.describe Condition, type: :model do
  subject(:condition) { described_class.new }

  it "has a valid factory" do
    condition = create :condition
    expect(condition).to be_valid
  end

  describe "versioning", versioning: true do
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

    context "when goto page has been deleted" do
      let(:condition) { create :condition, routing_page_id: routing_page.id, goto_page_id: 999 }

      it "returns object with error short name code " do
        expect(condition.warning_goto_page_doesnt_exist).to eq({ name: "goto_page_doesnt_exist" })
      end
    end

    context "when goto page may belong to another form" do
      let(:goto_page) { create :page }

      it "returns object with error short name code " do
        expect(condition.warning_goto_page_doesnt_exist).to eq({ name: "goto_page_doesnt_exist" })
      end
    end
  end
end

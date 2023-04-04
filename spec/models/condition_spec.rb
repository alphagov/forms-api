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
end

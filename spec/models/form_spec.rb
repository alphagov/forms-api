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
end

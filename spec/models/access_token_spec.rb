require "rails_helper"

RSpec.describe AccessToken, type: :model do
  subject(:access_token) { described_class.new }

  it "has a valid factory" do
    access_token = create :access_token
    expect(access_token).to be_valid
  end

  describe "validations" do
    it "requires a token" do
      expect(access_token).to be_invalid
      expect(access_token.errors[:token]).to include("can't be blank")
    end

    it "requires an owner" do
      expect(access_token).to be_invalid
      expect(access_token.errors[:owner]).to include("can't be blank")
    end
  end
end

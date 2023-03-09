require "rails_helper"

RSpec.describe AccessToken, type: :model do
  subject(:access_token) { described_class.new }

  it "has a valid factory" do
    access_token = create :access_token
    expect(access_token).to be_valid
  end
end

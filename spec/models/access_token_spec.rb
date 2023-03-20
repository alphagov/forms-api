require "rails_helper"

RSpec.describe AccessToken, type: :model do
  subject(:access_token) { described_class.new }

  let(:new_access_token) { described_class.create!(owner: "joe_bloggs") }

  before do
    allow(SecureRandom).to receive(:uuid).and_return("testing-123")
  end

  it "has a valid factory" do
    results = create :access_token
    expect(results).to be_valid
  end

  describe "validations" do
    it "requires an owner" do
      expect(access_token).to be_invalid
      expect(access_token.errors[:owner]).to include("can't be blank")
    end

    it "requires a token_digest" do
      expect(access_token).to be_invalid
      expect(access_token.errors[:token_digest]).to include("can't be blank")
    end
  end

  describe "scopes" do
    describe "#active" do
      let(:active_tokens) { create_list :access_token, 3 }
      let(:deactivated_tokens) { create_list :access_token, 3, deactivated_at: Time.zone.now }

      before do
        active_tokens
        deactivated_tokens
      end

      it "returns active tokens" do
        expect(described_class.active).to eq(active_tokens)
      end

      it "does not include deactivated tokens" do
        expect(described_class.active).not_to eq(deactivated_tokens)
      end
    end
  end

  describe "#generate_token" do
    let(:result) { access_token.generate_token }

    it "generates a user token before validation" do
      expect(result).to eq("testing-123")
    end

    it "generates a sha-256 token before validation" do
      result
      expect(access_token.token_digest).to eq("8d9754db9759ab1785644440dbf19f88ab45ae326e421da6c1cb6e45140d534f")
    end
  end
end

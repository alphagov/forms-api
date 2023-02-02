require "rails_helper"
require Rails.root.join("db/migrate/20230126135721_convert_address_to_uk_address.rb")

describe ConvertAddressToUkAddress do
  include MigrationHelpers

  let(:current_version) { 20230126135721 }
  let(:previous_version) { 20230126133557 }

  describe "#up" do
    before { migrate_to(previous_version) }

    it "converts existing ‘address‘ answer types to ‘uk_address‘ input types when nil" do
      page = create(:page, answer_type: "address")

      described_class.new.up

      expect(page.reload.answer_settings).to eq({ "input_type" => { "uk_address" => "true", "international_address" => "false" } })
    end
  end

  describe "#down" do
    before { migrate_to(current_version) }

    it "does not remove answer settings for ‘international_address‘ input types" do
      page_with_both = create(:page, answer_type: "address", answer_settings: { input_type: { uk_address: "true", international_address: "true" } })
      page_with_international_address = create(:page, answer_type: "address", answer_settings: { input_type: { uk_address: "false", international_address: "true" } })

      described_class.new.down

      expect(page_with_both.reload.answer_settings).to eq({ "input_type" => { "uk_address" => "true", "international_address" => "true" } })
      expect(page_with_international_address.reload.answer_settings).to eq({ "input_type" => { "uk_address" => "false", "international_address" => "true" } })
    end

    it "removes answer settings for ‘uk_address‘ only input types" do
      page = create(:page, answer_type: "address", answer_settings: { input_type: { uk_address: "true", international_address: "false" } })

      described_class.new.down

      expect(page.reload.answer_settings).to be_nil
    end
  end
end

require "rails_helper"
require Rails.root.join("db/migrate/20230126135721_convert_address_to_uk_address.rb")

describe ConvertAddressToUkAddress do
  include MigrationHelpers

  let(:previous_version) { 20230126133557 }

  describe "#up" do
    before { migrate_to(previous_version) }

    it "converts existing ‘address‘ answer types to ‘uk_address‘ input types when nil" do
      page = create(:page, answer_type: "address")

      described_class.new.up

      expect(page.reload.answer_settings).to eq({ "input_type" => { "uk_address" => "true", "international_address" => "false" } })
    end
  end
end

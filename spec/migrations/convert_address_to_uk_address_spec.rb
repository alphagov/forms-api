require "rails_helper"
require Rails.root.join('db/migrate/20230126135721_convert_address_to_uk_address.rb')

describe ConvertAddressToUkAddress do
  let(:migrations_paths) { ActiveRecord::Migrator.migrations_paths }
  let(:migrations) { ActiveRecord::MigrationContext.new(migrations_paths).migrations }
  let(:schema_migration) { ActiveRecord::SchemaMigration }
  let(:current_version) { 20230126135721 }
  let(:previous_version) { 20230126133557 }

  describe "#up" do
    before do
      ActiveRecord::Migration.suppress_messages do
        ActiveRecord::Migrator.new(:down, migrations, schema_migration, previous_version).migrate
      end
    end

    it "converts existing ‘address‘ answer types to ‘uk_address‘ input types when nil" do
      page = create(:page, answer_type: "address")

      described_class.new.up

      expect(page.reload.answer_settings).to eq({ "input_type" => { "uk_address" => "true", "international_address" => "false" } })
    end
  end

  describe "#down" do
    before do
      ActiveRecord::Migration.suppress_messages do
        ActiveRecord::Migrator.new(:up, migrations, schema_migration, current_version).migrate
      end
    end

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

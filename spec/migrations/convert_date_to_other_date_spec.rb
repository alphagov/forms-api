require "rails_helper"
require Rails.root.join('db/migrate/20230126133557_convert_date_to_other_date.rb')

describe ConvertDateToOtherDate do
  let(:migrations_paths) { ActiveRecord::Migrator.migrations_paths }
  let(:migrations) { ActiveRecord::MigrationContext.new(migrations_paths).migrations }
  let(:schema_migration) { ActiveRecord::SchemaMigration }
  let(:current_version) { 20230126133557 }
  let(:previous_version) { 20221222115429 }

  describe "#up" do
    before do
      ActiveRecord::Migration.suppress_messages do
        ActiveRecord::Migrator.new(:down, migrations, schema_migration, previous_version).migrate
      end
    end

    it "converts existing date input types to ‘other_date‘ when nil" do
      page = create(:page, answer_type: "date")

      described_class.new.up

      expect(page.reload.answer_settings).to eq({ "input_type" => "other_date" })
    end
  end

  describe "#down" do
    before do
      ActiveRecord::Migration.suppress_messages do
        ActiveRecord::Migrator.new(:up, migrations, schema_migration, current_version).migrate
      end
    end

    it "does not remove answer settings for ‘date_of_birth‘ input types" do
      page = create(:page, answer_type: "date", answer_settings: { input_type: "date_of_birth" })

      described_class.new.down

      expect(page.reload.answer_settings).to eq({ "input_type" => "date_of_birth" })
    end

    it "removes answer settings for ‘other_date‘ input types" do
      page = create(:page, answer_type: "date", answer_settings: { input_type: "other_date" })

      described_class.new.down

      expect(page.reload.answer_settings).to be_nil
    end
  end
end

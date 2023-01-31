require "rails_helper"
require Rails.root.join('db/migrate/20230126141136_convert_old_text_fields_to_new_text_fields.rb')

describe ConvertOldTextFieldsToNewTextFields do
  let(:migrations_paths) { ActiveRecord::Migrator.migrations_paths }
  let(:migrations) { ActiveRecord::MigrationContext.new(migrations_paths).migrations }
  let(:schema_migration) { ActiveRecord::SchemaMigration }
  let(:current_version) { 20230126141136 }
  let(:previous_version) { 20230126135721 }

  describe "#up" do
    before do
      ActiveRecord::Migration.suppress_messages do
        ActiveRecord::Migrator.new(:down, migrations, schema_migration, previous_version).migrate
      end
    end

    it "converts existing ‘single_line‘ answer types to ‘text‘ answer types with ‘single_line‘ input types" do
      page = create(:page, answer_type: "single_line")

      described_class.new.up

      expect(page.reload.answer_type).to eq("text")
      expect(page.reload.answer_settings).to eq({ "input_type" => "single_line" })
    end

    it "converts existing ‘long_text‘ answer types to ‘text‘ answer types with ‘long_text‘ input types" do
      page = create(:page, answer_type: "long_text")

      described_class.new.up

      expect(page.reload.answer_type).to eq("text")
      expect(page.reload.answer_settings).to eq({ "input_type" => "long_text" })
    end
  end

  describe "#down" do
    before do
      ActiveRecord::Migration.suppress_messages do
        ActiveRecord::Migrator.new(:up, migrations, schema_migration, current_version).migrate
      end
    end

    it "converts existing ‘single_line‘ input types to ‘single_line‘ answer types with no answer settings" do
      page = create(:page, answer_type: "text", answer_settings: { input_type: "single_line" })

      described_class.new.down

      expect(page.reload.answer_type).to eq("single_line")
      expect(page.reload.answer_settings).to be_nil
    end

    it "converts existing ‘long_text‘ input types to ‘long_text‘ answer types with no answer settings" do
      page = create(:page, answer_type: "text", answer_settings: { input_type: "long_text" })

      described_class.new.down

      expect(page.reload.answer_type).to eq("long_text")
      expect(page.reload.answer_settings).to be_nil
    end
  end
end

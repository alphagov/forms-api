require "rails_helper"
require Rails.root.join("db/migrate/20230126141136_convert_old_text_fields_to_new_text_fields.rb")

describe ConvertOldTextFieldsToNewTextFields do
  include MigrationHelpers

  let(:current_version) { 20230126141136 }
  let(:previous_version) { 20230126135721 }

  describe "#up" do
    before { migrate_to(previous_version) }

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
    before { migrate_to(current_version) }

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

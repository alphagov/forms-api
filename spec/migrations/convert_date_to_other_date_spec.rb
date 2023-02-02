require "rails_helper"
require Rails.root.join("db/migrate/20230126133557_convert_date_to_other_date.rb")

describe ConvertDateToOtherDate do
  include MigrationHelpers

  let(:current_version) { 20230126133557 }
  let(:previous_version) { 20221222115429 }

  describe "#up" do
    before { migrate_to(previous_version) }

    it "converts existing date input types to ‘other_date‘ when nil" do
      page = create(:page, answer_type: "date")

      described_class.new.up

      expect(page.reload.answer_settings).to eq({ "input_type" => "other_date" })
    end
  end

  describe "#down" do
    before { migrate_to(current_version) }

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

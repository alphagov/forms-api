require "rails_helper"
require Rails.root.join("db/migrate/20230126133557_convert_date_to_other_date.rb")

describe ConvertDateToOtherDate do
  include MigrationHelpers

  let(:previous_version) { 20221222115429 }

  describe "#up" do
    before do
      migrate_to(previous_version)
    end

    it "converts existing date input types to ‘other_date‘ when nil" do
      page = create(:page, answer_type: "date")
      described_class.new.up

      expect(page.reload.answer_settings).to eq({ "input_type" => "other_date" })
    end
  end
end

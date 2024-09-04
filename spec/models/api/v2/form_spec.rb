require "rails_helper"

RSpec.describe Api::V2::Form, type: :model do
  it "uses the same database records as the v1 API Form model" do
    api_v1_form = create :form
    expect(described_class.last.attributes).to eq api_v1_form.attributes
  end

  describe "#as_json" do
    it "uses the external ID as the ID" do
      form = described_class.create! external_id: "baz"
      expect(form.as_json).to include id: "baz"
    end

    it "includes links to itself and the form's documents" do
      form = create :form, :live
      form.update! external_id: "qux"
      allow(Api::V2::FormDocumentRepository).to receive(:tags_for_form).and_return %i[draft live]
      form = described_class.find form.id
      expect(form.as_json).to include(
        links: {
          self: a_string_ending_with("/qux"),
          draft: a_string_ending_with("/qux/draft"),
          live: a_string_ending_with("/qux/live"),
        },
      )
    end
  end
end

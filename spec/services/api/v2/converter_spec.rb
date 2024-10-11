require "rails_helper"

RSpec.describe Api::V2::Converter do
  let(:converter) { described_class.new }

  describe "#to_api_v2_document" do
    let(:form_snapshot) { create(:form).snapshot }
    let(:form_document) { converter.to_api_v2_form_document(form_snapshot) }

    it "takes a form snapshot and turns it into a v2 API form document" do
      expect(form_document).to be_a Hash
    end

    it "includes all the form snapshot data" do
      expect(form_document).to include(**form_snapshot.except("id", "pages"))
    end

    it "can prepend a form ID" do
      expect(converter.to_api_v2_form_document(form_snapshot, form_id: "foobar"))
        .to include("form_id" => "foobar")
    end

    context "when the form snapshot has pages" do
      let(:form_snapshot) { create(:form, :with_pages).snapshot }

      it "transforms pages to steps" do
        expect(form_document).not_to include "pages"
        expect(form_document).to include "steps"
      end

      it "has a step for each page" do
        expect(form_document["steps"].pluck("id"))
          .to eq form_snapshot["pages"].pluck("id")
      end

      it "links each step to the next in order" do
        steps = form_document["steps"]
        steps.each_with_index do |step, index|
          next_step = steps.fetch(index + 1, {})
          expect(step).to include "next_step_id" => next_step["id"]
        end
      end

      it "includes routing conditions in steps" do
        expect(form_document["steps"])
          .to all include("routing_conditions")
      end

      it "includes data for questions in steps" do
        page_attributes = Page.attribute_names - %w[id form_id next_page position created_at updated_at]
        expect(form_document["steps"])
          .to all include(
            "type" => "question_page",
            "data" => a_hash_including(*page_attributes),
          )
      end
    end
  end
end

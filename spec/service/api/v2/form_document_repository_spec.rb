require "rails_helper"

RSpec.describe Api::V2::FormDocumentRepository do
  describe ".find" do
    it "finds a form document given form id and document tag" do
      form = create :form
      expect(described_class.find(form.id, :draft)).to be_truthy
    end

    it "returns a JSON object" do
      form = create :form
      form_document = described_class.find(form.id, :draft)
      expect(form_document.as_json).to eq form_document
    end

    it "raises an exception if the form does not exist" do
      expect {
        described_class.find("not_a_form", :draft)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "raises an exception if the form does not have a document for the given tag" do
      form = create :form
      expect {
        described_class.find(form.id, :live)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context "when there is a v1 form for the given form id" do
      let(:form) { create :form }

      it "returns a v2 form document" do
        form = create :form, :with_pages
        expect(described_class.find(form.id, :draft))
          .to include("steps")
      end

      it "uses the current form snapshot if the draft tag is given" do
        form.update! name: "Edited form"
        expect(described_class.find(form.id, :draft))
          .to include("name" => "Edited form")
      end

      it "includes the form external ID" do
        form.update! external_id: "xyzzy"
        expect(described_class.find(form.id, :draft))
          .to include("form_id" => "xyzzy")
      end

      context "when the form has been made live" do
        let(:form) { create :form, :live, name: "Test form" }

        it "uses the made live form snapshot if the live tag is given" do
          expect(described_class.find(form.id, :live))
            .to include("name" => "Test form")
        end

        it "uses the current form snapshot if the draft tag is given" do
          expect(described_class.find(form.id, :draft))
            .to include("name" => "Test form")
        end

        it "raises an exception if the archived tag is given" do
          expect {
            described_class.find(form.id, :archived)
          }.to raise_error(ActiveRecord::RecordNotFound)
        end

        context "and then edited" do
          before do
            form.update! name: "Edited form"
            form.create_draft_from_live_form!
          end

          it "uses the made live form snapshot if the live tag is given" do
            expect(described_class.find(form.id, :live))
              .to include("name" => "Test form")
          end

          it "uses the current form snapshot if the draft tag is given" do
            expect(described_class.find(form.id, :draft))
              .to include("name" => "Edited form")
          end

          it "raises an exception if the archived tag is given" do
            expect {
              described_class.find(form.id, :archived)
            }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end

      context "when the form has been archived" do
        let(:form) { create :form, :archived, name: "Test form" }

        it "uses the made live form snapshot if the archived tag is given" do
          expect(described_class.find(form.id, :archived))
            .to include("name" => "Test form")
        end

        it "uses the current form snapshot if the draft tag is given" do
          expect(described_class.find(form.id, :draft))
            .to include("name" => "Test form")
        end

        it "raises an exception if the live tag is given" do
          expect {
            described_class.find(form.id, :live)
          }.to raise_error(ActiveRecord::RecordNotFound)
        end

        context "and then edited" do
          before do
            form.update! name: "Edited form"
            form.create_draft_from_archived_form!
          end

          it "uses the made live form snapshot if the archived tag is given" do
            expect(described_class.find(form.id, :archived))
              .to include("name" => "Test form")
          end

          it "uses the current form snapshot if the draft tag is given" do
            expect(described_class.find(form.id, :draft))
              .to include("name" => "Edited form")
          end

          it "raises an exception if the live tag is given" do
            expect {
              described_class.find(form.id, :live)
            }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end
  end

  describe ".tags_for_form" do
    it "returns tags for all documents that exist for the given form" do
      form = create :form, :live
      form.create_draft_from_live_form!
      expect(described_class.tags_for_form(form.id)).to include :draft, :live
    end

    context "when there is a v1 form for the given form id" do
      subject(:tags_for_form) { described_class.tags_for_form(form.id) }

      let(:form) { create :form }

      it { is_expected.to contain_exactly(:draft) }

      context "and the form has been made live" do
        let(:form) { create :form, :live }

        it { is_expected.to contain_exactly(:live) }

        context "and then edited" do
          before do
            form.create_draft_from_live_form!
          end

          it { is_expected.to contain_exactly(:live, :draft) }
        end
      end

      context "when the form has been archived" do
        let(:form) { create :form, :archived }

        it { is_expected.to contain_exactly(:archived) }

        context "and then edited" do
          before do
            form.create_draft_from_archived_form!
          end

          it { is_expected.to contain_exactly(:archived, :draft) }
        end
      end
    end
  end
end

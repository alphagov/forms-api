require "rails_helper"

RSpec.describe Api::V2::ModelSync do
  subject(:model_sync) { described_class.new }

  let(:form_id) { form.id }
  let(:form) { create :form }
  let(:external_id) { "external_123" }
  let(:form_blob) { { "title" => "Test Form" } }
  let(:api_converter) { instance_double(Api::V2::Converter) }

  before do
    allow(Api::V2::Converter).to receive(:new).and_return(api_converter)
    allow(api_converter).to receive(:to_api_v2_form_document).and_return({ data: { **form_blob } })
  end

  describe "#create_form" do
    it "creates a new draft form document" do
      expect {
        model_sync.create_form(form_id, external_id, form_blob)
      }.to change(Api::V2::FormDocument, :count).by(1)

      form_document = Api::V2::FormDocument.last
      expect(form_document.form_id).to eq(form_id)
      expect(form_document.tag).to eq("draft")
      expect(form_document.content).to be_present
      expect(api_converter).to have_received(:to_api_v2_form_document).with(form_blob, form_id: external_id)
    end
  end

  describe "#update_draft" do
    it "updates an existing draft form document" do
      existing_draft = Api::V2::FormDocument.create!(form_id:, tag: :draft, content: {})

      model_sync.update_draft(form_id, form_blob, external_id)

      existing_draft.reload
      expect(existing_draft.content).to be_present
      expect(api_converter).to have_received(:to_api_v2_form_document).with(form_blob, form_id: external_id)
    end

    it "creates a new draft form document if it does not exist" do
      expect {
        model_sync.update_draft(form_id, form_blob, external_id)
      }.to change(Api::V2::FormDocument, :count).by(1)

      form_document = Api::V2::FormDocument.last
      expect(form_document.form_id).to eq(form_id)
      expect(form_document.tag).to eq("draft")
      expect(form_document.content).to be_present
      expect(api_converter).to have_received(:to_api_v2_form_document).with(form_blob, form_id: external_id)
    end
  end

  describe "#make_live" do
    it "creates or updates a live form document" do
      model_sync.make_live(form_id, form_blob, :draft, external_id)

      form_document = Api::V2::FormDocument.find_by(form_id:, tag: :live)
      expect(form_document).to be_present
      expect(form_document.content).to be_present
      expect(api_converter).to have_received(:to_api_v2_form_document).with(form_blob, form_id: external_id)
    end

    it "removes draft version when making live from draft state" do
      Api::V2::FormDocument.create!(form_id:, tag: :draft, content: {})

      expect {
        model_sync.make_live(form_id, form_blob, :draft, external_id)
      }.to change { Api::V2::FormDocument.where(form_id:, tag: :draft).count }.from(1).to(0)
    end

    it "removes archived version when making live from archived state" do
      Api::V2::FormDocument.create!(form_id:, tag: :archived, content: {})

      expect {
        model_sync.make_live(form_id, form_blob, :archived, external_id)
      }.to change { Api::V2::FormDocument.where(form_id:, tag: :archived).count }.from(1).to(0)
    end
  end

  describe "#archive_live_form" do
    it "creates an archived form document" do
      expect {
        model_sync.archive_live_form(form_id, form_blob, external_id)
      }.to change { Api::V2::FormDocument.where(form_id:, tag: :archived).count }.by(1)

      expect(api_converter).to have_received(:to_api_v2_form_document).with(form_blob, form_id: external_id)
    end

    it "removes the live form document" do
      Api::V2::FormDocument.create!(form_id:, tag: :live, content: {})

      expect {
        model_sync.archive_live_form(form_id, form_blob, external_id)
      }.to change { Api::V2::FormDocument.where(form_id:, tag: :live).count }.from(1).to(0)
    end
  end
end

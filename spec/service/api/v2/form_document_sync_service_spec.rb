require "rails_helper"

RSpec.describe Api::V2::FormDocumentSyncService do
  let(:service) { described_class.new }
  let(:form) { create(:form) }
  let(:converter) { instance_double(Api::V2::Converter) }

  before do
    allow(Api::V2::Converter).to receive(:new).and_return(converter)
    allow(converter).to receive(:to_api_v2_form_document).and_return({})
  end

  describe "#synchronize_form" do
    context "when form state is live" do
      before { allow(form).to receive(:state).and_return("live") }

      it "calls sync_live_form" do
        expect(service).to receive(:sync_live_form).with(form)
        service.synchronize_form(form)
      end
    end

    context "when form state is live_with_draft" do
      before { allow(form).to receive(:state).and_return("live_with_draft") }

      it "calls sync_live_with_draft_form" do
        expect(service).to receive(:sync_live_with_draft_form).with(form)
        service.synchronize_form(form)
      end
    end

    context "when form state is draft" do
      before { allow(form).to receive(:state).and_return("draft") }

      it "calls sync_draft_form" do
        expect(service).to receive(:sync_draft_form).with(form)
        service.synchronize_form(form)
      end
    end

    context "when form state is archived" do
      before { allow(form).to receive(:state).and_return("archived") }

      it "calls sync_archived_form" do
        expect(service).to receive(:sync_archived_form).with(form)
        service.synchronize_form(form)
      end
    end

    context "when form state is archived_with_draft" do
      before { allow(form).to receive(:state).and_return("archived_with_draft") }

      it "calls sync_archived_with_draft_form" do
        expect(service).to receive(:sync_archived_with_draft_form).with(form)
        service.synchronize_form(form)
      end
    end
  end

  describe "#sync_live_form" do
    let(:form) { create(:form, :live) }

    it "updates or creates live form document and deletes draft and archived documents" do
      expect(service).to receive(:update_or_create_form_document).with(form, :live, anything)
      expect(service).to receive(:delete_form_documents).with(form, %i[draft archived])
      service.sync_live_form(form)
    end
  end

  describe "#sync_live_with_draft_form" do
    let(:form) { create(:form, :live) }

    it "updates or creates live and draft form documents and deletes archived document" do
      expect(service).to receive(:update_or_create_form_document).with(form, :live, anything)
      expect(service).to receive(:update_or_create_form_document).with(form, :draft, anything)
      expect(service).to receive(:delete_form_documents).with(form, [:archived])
      service.sync_live_with_draft_form(form)
    end
  end

  describe "#sync_draft_form" do
    it "updates or creates draft form document and deletes live and archived documents" do
      expect(service).to receive(:update_or_create_form_document).with(form, :draft, anything)
      expect(service).to receive(:delete_form_documents).with(form, %i[live archived])
      service.sync_draft_form(form)
    end
  end

  describe "#sync_archived_form" do
    it "updates or creates archived form document and deletes live and draft documents" do
      expect(service).to receive(:update_or_create_form_document).with(form, :archived, anything)
      expect(service).to receive(:delete_form_documents).with(form, %i[live draft])
      service.sync_archived_form(form)
    end
  end

  describe "#sync_archived_with_draft_form" do
    it "updates or creates archived and draft form documents and deletes live document" do
      expect(service).to receive(:update_or_create_form_document).with(form, :archived, anything)
      expect(service).to receive(:update_or_create_form_document).with(form, :draft, anything)
      expect(service).to receive(:delete_form_documents).with(form, [:live])
      service.sync_archived_with_draft_form(form)
    end
  end

  describe "#update_or_create_form_document" do
    let(:form_document) { instance_double(Api::V2::FormDocument, save!: true) }

    before do
      allow(Api::V2::FormDocument).to receive(:find_or_initialize_by).and_return(form_document)
    end

    it "finds or initializes a form document and updates its content" do
      expect(Api::V2::FormDocument).to receive(:find_or_initialize_by).with(form_id: form.id, tag: :live)
      expect(form_document).to receive(:content=)
      expect(form_document).to receive(:save!)
      service.update_or_create_form_document(form, :live, {})
    end
  end

  describe "#delete_form_documents" do
    it "deletes form documents with specified tags" do
      create(:form_document, form_id: form.id, tag: :draft)
      create(:form_document, form_id: form.id, tag: :archived)
      create(:form_document, form_id: form.id, tag: :live)

      expect {
        service.delete_form_documents(form, %i[live draft archived])
      }.to change(Api::V2::FormDocument, :count).from(3).to(0)
    end
  end
end

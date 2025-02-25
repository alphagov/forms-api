RSpec.shared_examples "transition to live state" do |form_object, form_state|
  let(:form) { form_object.new(state: form_state) }
  let(:form_document_sync_service) { instance_double(Api::V2::FormDocumentSyncService) }

  before do
    allow(form).to receive(:ready_for_live).and_return(true)
    allow(Api::V2::FormDocumentSyncService).to receive(:new).and_return(form_document_sync_service)
    allow(form_document_sync_service).to receive(:synchronize_form)
  end

  it "transitions to live state" do
    freeze_time do
      time_now = Time.zone.now
      form_snapshot = build(:form)
      allow(form).to receive(:touch)
      allow(form).to receive(:snapshot)
                        .with(live_at: time_now)
                        .and_return(form_snapshot)
      allow(form.made_live_forms).to receive(:create!).with(json_form_blob: form_snapshot.to_json, created_at: time_now)

      expect(form).to transition_from(form_state).to(:live).on_event(:make_live)
    end
  end
end

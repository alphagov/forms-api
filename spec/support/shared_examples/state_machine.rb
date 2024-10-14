RSpec.shared_examples "transition to live state" do |form_object, form_state|
  let(:form) { form_object.new(state: form_state) }
  let(:form_sync) { instance_double(Api::V2::ModelSync) }

  before do
    allow(form_sync).to receive(:make_live)
    allow(form_sync).to receive(:archive_live_form)
    allow(form).to receive_messages(ready_for_live: true, form_sync:)
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

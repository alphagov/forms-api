require "rails_helper"

RSpec.describe MadeLiveForm, type: :model do
  let(:made_live_form) { create :made_live_form }

  it "has a valid factory" do
    expect(made_live_form).to be_valid
  end

  it "contains a snapshot of a form" do
    expect(made_live_form.json_form_blob).to eq made_live_form.form.snapshot.to_json
  end
end

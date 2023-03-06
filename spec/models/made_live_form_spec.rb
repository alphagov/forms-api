require "rails_helper"

RSpec.describe MadeLiveForm, type: :model do
  let(:made_live_form) { create :made_live_form }

  it "has a valid factory" do
    expect(made_live_form).to be_valid
  end

  it "contains a version of a form with its pages" do
    expect(made_live_form.json_form_blob).to eq made_live_form.form.to_json(include: [:pages])
  end
end

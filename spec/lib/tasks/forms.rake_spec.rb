require "rake"

require "rails_helper"

RSpec.describe "forms.rake" do
  before do
    Rake.application.rake_require "tasks/forms"
    Rake::Task.define_task(:environment)
  end

  describe "forms:set_external_ids" do
    subject(:task) do
      Rake::Task["forms:set_external_ids"]
        .tap(&:reenable)
    end

    let(:form) { create :form, id: form_id }
    let(:form_id) { 3 }

    it "sets a form's external_id to its id" do
      form.update!(external_id: nil)
      expect { task.invoke }
        .to change { form.reload.external_id }.to(form_id.to_s)
        .and output(/external_id has been set for each form to their id/)
              .to_stdout
    end
  end
end

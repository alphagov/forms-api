require "rake"

require "rails_helper"

RSpec.describe "forms.rake" do
  before do
    Rake.application.rake_require "tasks/forms"
    Rake::Task.define_task(:environment)
  end

  describe "forms:update_organisation" do
    subject(:task) do
      Rake::Task["forms:update_organisation"]
        .tap(&:reenable) # make sure task is invoked every time
    end

    let(:form) { create :form, id: 1, organisation_id: 1 }
    let(:target_organisation_id) { 2 }

    it "aborts when the form is not found" do
      expect { task.invoke(2, target_organisation_id) }
        .to output(/Form with ID: 2 not found/)
              .to_stderr
              .and raise_error(SystemExit) { |e| expect(e).not_to be_success }
    end

    it "updates the organisation for a form" do
      expect { task.invoke(form.id, target_organisation_id) }
        .to change { form.reload.organisation_id }.to(target_organisation_id)
        .and output(/Updated organisation for Form: 1 to be 2/)
              .to_stdout
    end
  end
end

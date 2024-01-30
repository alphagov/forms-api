require "rails_helper"
require "rake"

RSpec.describe "forms_admin.rake" do
  describe "forms_admin:make_unlive", type: :task do
    before do
      Rake.application.rake_require "tasks/forms_admin"
      Rake::Task.define_task(:environment)
    end

    it "makes a given form unlive" do
      form = create(:made_live_form).form
      expect(form.has_live_version).to be true

      Rake::Task["forms_admin:make_unlive"].invoke(form.id)

      form.reload
      expect(form.made_live_forms.present?).to be false
      expect(form.has_live_version).to be false
      expect(form).to transition_from(:live).to(:draft).on_event(:archive_live_form)
    end

    it "does not make a form unlive if it has no live version" do
      form = create(:form)
      expect(form.has_live_version).to be false

      Rake::Task["forms_admin:make_unlive"].invoke(form.id)

      form.reload
      expect(form.has_live_version).to be false
    end
  end
end

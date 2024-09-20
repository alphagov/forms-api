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

    let(:form) { create :form }

    it "sets a form's external_id to its id" do
      form.update!(external_id: nil)
      expect { task.invoke }
        .to change { form.reload.external_id }.to(form.id.to_s)
        .and output(/external_id has been set for each form to their id/)
              .to_stdout
    end
  end

  describe "forms:set_submission_type_to_email_with_csv" do
    subject(:task) do
      Rake::Task["forms:set_submission_type_to_email_with_csv"]
        .tap(&:reenable)
    end

    let(:form) { create :form, :live }
    let!(:other_form) { create :form, :live }

    context "when the form is live" do
      before do
        # make this form live twice to create multiple versions
        form.create_draft_from_live_form!
        form.make_live!
      end

      it "sets a form's submission_type to email_with_csv" do
        expect { task.invoke(form.id) }
          .to change { form.reload.submission_type }.to("email_with_csv")
      end

      it "does not update a form's older live versions" do
        task.invoke(form.id)
        expect(JSON.parse(form.made_live_forms.first.json_form_blob)["submission_type"]).to eq("email")
      end

      it "updates a form's latest live version" do
        task.invoke(form.id)
        expect(JSON.parse(form.made_live_forms.last.json_form_blob)["submission_type"]).to eq("email_with_csv")
      end

      it "does not update a different form" do
        expect { task.invoke(form.id) }
          .not_to(change { other_form.reload.submission_type })
      end

      it "does not update a different form's latest live version" do
        task.invoke(form.id)
        expect(JSON.parse(other_form.made_live_forms.last.json_form_blob)["submission_type"]).to eq("email")
      end
    end

    context "when the form is not live" do
      it "sets a form's submission_type to email_with_csv" do
        expect { task.invoke(form.id) }
          .to change { form.reload.submission_type }.to("email_with_csv")
      end
    end
  end
end

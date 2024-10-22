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
        .to change { form.reload.external_id }
              .to(form.id.to_s)
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
        form.share_preview_completed = true
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

    context "when the form is archived" do
      before do
        form.create_draft_from_live_form!
        form.archive_live_form!
      end

      it "sets a form's submission_type to email_with_csv" do
        expect { task.invoke(form.id) }
          .to change { form.reload.submission_type }.to("email_with_csv")
      end

      it "does not update the forms latest made live version" do
        task.invoke(form.id)
        expect(JSON.parse(form.made_live_forms.last.json_form_blob)["submission_type"]).to eq("email")
      end
    end
  end

  describe "forms:set_submission_type_to_s3" do
    subject(:task) do
      Rake::Task["forms:set_submission_type_to_s3"]
        .tap(&:reenable)
    end

    let(:form) { create :form, :live }
    let!(:other_form) { create :form, :live }
    let(:s3_bucket_name) { "a-bucket" }
    let(:s3_bucket_aws_account_id) { "an-aws-account-id" }
    let(:s3_bucket_region) { "eu-west-1" }

    context "when the form is live" do
      before do
        # make this form live twice to create multiple versions
        form.create_draft_from_live_form!
        form.share_preview_completed = true
        form.make_live!
      end

      it "sets a form's submission_type to s3" do
        expect { task.invoke(form.id, s3_bucket_name, s3_bucket_aws_account_id, s3_bucket_region) }
          .to change { form.reload.submission_type }.to("s3")
      end

      it "sets a form's s3_bucket_name" do
        expect { task.invoke(form.id, s3_bucket_name, s3_bucket_aws_account_id, s3_bucket_region) }
          .to change { form.reload.s3_bucket_name }.to(s3_bucket_name)
      end

      it "sets a form's s3_bucket_aws_account_id" do
        expect { task.invoke(form.id, s3_bucket_name, s3_bucket_aws_account_id, s3_bucket_region) }
          .to change { form.reload.s3_bucket_aws_account_id }.to(s3_bucket_aws_account_id)
      end

      it "does not update a form's older live versions" do
        task.invoke(form.id, s3_bucket_name, s3_bucket_aws_account_id, s3_bucket_region)
        expect(JSON.parse(form.made_live_forms.first.json_form_blob)["submission_type"]).to eq("email")
        expect(JSON.parse(form.made_live_forms.first.json_form_blob)["s3_bucket_name"]).to be_nil
      end

      it "updates a form's latest live version" do
        task.invoke(form.id, s3_bucket_name, s3_bucket_aws_account_id, s3_bucket_region)
        expect(JSON.parse(form.made_live_forms.last.json_form_blob)["submission_type"]).to eq("s3")
        expect(JSON.parse(form.made_live_forms.last.json_form_blob)["s3_bucket_name"]).to eq(s3_bucket_name)
      end

      it "does not update a different form" do
        expect { task.invoke(form.id, s3_bucket_name, s3_bucket_aws_account_id, s3_bucket_region) }
          .not_to(change { other_form.reload.submission_type })
      end

      it "does not update a different form's latest live version" do
        task.invoke(form.id, s3_bucket_name, s3_bucket_aws_account_id, s3_bucket_region)
        expect(JSON.parse(other_form.made_live_forms.last.json_form_blob)["submission_type"]).to eq("email")
      end
    end

    context "when the form is not live" do
      it "sets a form's submission_type to s3" do
        expect { task.invoke(form.id, s3_bucket_name, s3_bucket_aws_account_id, s3_bucket_region) }
          .to change { form.reload.submission_type }.to("s3")
      end

      it "sets a form's s3_bucket_name" do
        expect { task.invoke(form.id, s3_bucket_name, s3_bucket_aws_account_id, s3_bucket_region) }
          .to change { form.reload.s3_bucket_name }.to(s3_bucket_name)
      end

      it "sets a form's s3_bucket_aws_account_id" do
        expect { task.invoke(form.id, s3_bucket_name, s3_bucket_aws_account_id, s3_bucket_region) }
          .to change { form.reload.s3_bucket_aws_account_id }.to(s3_bucket_aws_account_id)
      end
    end

    context "when the form is archived" do
      before do
        form.create_draft_from_live_form!
        form.archive_live_form!
      end

      it "sets a form's submission_type to s3" do
        expect { task.invoke(form.id, s3_bucket_name, s3_bucket_aws_account_id, s3_bucket_region) }
          .to change { form.reload.submission_type }.to("s3")
      end

      it "does not update the forms latest made live version" do
        task.invoke(form.id, s3_bucket_name, s3_bucket_aws_account_id, s3_bucket_region)
        expect(JSON.parse(form.made_live_forms.last.json_form_blob)["submission_type"]).to eq("email")
      end
    end

    context "without arguments" do
      it "aborts with a usage message" do
        expect {
          task.invoke
        }.to raise_error(SystemExit)
               .and output("usage: rake forms:set_submission_type_to_s3[<form_id>, <s3_bucket_name>, <s3_bucket_aws_account_id>, <s3_bucket_region>]\n").to_stderr
      end
    end

    context "without bucket name argument" do
      it "aborts with a usage message" do
        expect {
          task.invoke(1)
        }.to raise_error(SystemExit)
               .and output("usage: rake forms:set_submission_type_to_s3[<form_id>, <s3_bucket_name>, <s3_bucket_aws_account_id>, <s3_bucket_region>]\n").to_stderr
      end
    end

    context "without AWS account ID argument" do
      it "aborts with a usage message" do
        expect {
          task.invoke(1, s3_bucket_name)
        }.to raise_error(SystemExit)
               .and output("usage: rake forms:set_submission_type_to_s3[<form_id>, <s3_bucket_name>, <s3_bucket_aws_account_id>, <s3_bucket_region>]\n").to_stderr
      end
    end

    context "without region argument" do
      it "aborts with a usage message" do
        expect {
          task.invoke(1, s3_bucket_name, s3_bucket_aws_account_id)
        }.to raise_error(SystemExit)
               .and output("usage: rake forms:set_submission_type_to_s3[<form_id>, <s3_bucket_name>, <s3_bucket_aws_account_id>, <s3_bucket_region>]\n").to_stderr
      end
    end

    context "when region is not allowed" do
      it "aborts with message" do
        expect {
          task.invoke(1, s3_bucket_name, s3_bucket_aws_account_id, "eu-west-3")
        }.to raise_error(SystemExit)
               .and output("s3_bucket_region must be one of eu-west-1 or eu-west-2\n").to_stderr
      end
    end
  end

  describe "forms:set_submission_type_to_email" do
    subject(:task) do
      Rake::Task["forms:set_submission_type_to_email"]
        .tap(&:reenable)
    end

    let(:form) { create :form, :live, submission_type: "s3" }
    let!(:other_form) { create :form, :live, submission_type: "s3" }

    context "when the form is live" do
      before do
        # make this form live twice to create multiple versions
        form.create_draft_from_live_form!
        form.share_preview_completed = true
        form.make_live!
      end

      it "sets a form's submission_type to email" do
        expect { task.invoke(form.id) }
          .to change { form.reload.submission_type }.to("email")
      end

      it "does not update a form's older live versions" do
        task.invoke(form.id)
        expect(JSON.parse(form.made_live_forms.first.json_form_blob)["submission_type"]).to eq("s3")
      end

      it "updates a form's latest live version" do
        task.invoke(form.id)
        expect(JSON.parse(form.made_live_forms.last.json_form_blob)["submission_type"]).to eq("email")
      end

      it "does not update a different form" do
        expect { task.invoke(form.id) }
          .not_to(change { other_form.reload.submission_type })
      end

      it "does not update a different form's latest live version" do
        task.invoke(form.id)
        expect(JSON.parse(other_form.made_live_forms.last.json_form_blob)["submission_type"]).to eq("s3")
      end
    end

    context "when the form is not live" do
      it "sets a form's submission_type to email" do
        expect { task.invoke(form.id) }
          .to change { form.reload.submission_type }.to("email")
      end
    end

    context "when the form is archived" do
      before do
        form.create_draft_from_live_form!
        form.archive_live_form!
      end

      it "sets a form's submission_type to email" do
        expect { task.invoke(form.id) }
          .to change { form.reload.submission_type }.to("email")
      end

      it "does not update the forms latest made live version" do
        task.invoke(form.id)
        expect(JSON.parse(form.made_live_forms.last.json_form_blob)["submission_type"]).to eq("s3")
      end
    end
  end

  describe "forms:synchronise_form_documents" do
    subject(:task) do
      Rake::Task["forms:synchronise_form_documents"]
        .tap(&:reenable)
    end

    let(:form) { create :form }

    let(:draft_document) { Api::V2::FormDocument.find_by(form_id: form.id, tag: "draft") }
    let(:live_document) { Api::V2::FormDocument.find_by(form_id: form.id, tag: "live") }
    let(:archived_document) { Api::V2::FormDocument.find_by(form_id: form.id, tag: "archived") }

    def create_live_form(form)
      live_at ||= Time.zone.now
      # make a live form without invoking the state machine, which will trigger model syncing code

      form.touch(time: live_at)

      form_blob = form.snapshot(live_at:)
      form.made_live_forms.create!(json_form_blob: form_blob.to_json, created_at: live_at)
      form.live!
    end

    shared_examples "does not change FormDocuments when invoked twice" do
      it "does not create additional documents on multiple invocations" do
        task.invoke
        expect {
          task.invoke
        }.not_to(change { Api::V2::FormDocument.where(form_id: form.id).count })
      end
    end

    context "when the form is live" do
      let(:form) { create :form, :ready_for_live }

      before do
        create_live_form(form)
      end

      it "ensures the there is one FormDocument with the live tag" do
        task.invoke
        expect(live_document).to have_attributes(tag: "live", content: hash_including("form_id" => form.external_id))
        expect(draft_document).to be_nil
        expect(archived_document).to be_nil
      end

      it "updates FormDocument with 'live' tag if it already exists" do
        create :form_document, form_id: form.id, tag: "live", content: { "submission_email" => "old_live_form@example.com" }

        task.invoke

        expect(live_document).to have_attributes(tag: "live", content: hash_including("submission_email" => form.submission_email))
        expect(draft_document).to be_nil
        expect(archived_document).to be_nil
      end

      it "removes any archived FormDocuments" do
        create :form_document, form_id: form.id, tag: "archived"

        task.invoke

        expect(archived_document).to be_nil
      end

      include_examples "does not change FormDocuments when invoked twice"
    end

    context "when the form is live_with_draft" do
      let(:form) { create :form, :ready_for_live, submission_email: "original_submission_email@example.com" }

      before do
        create_live_form(form)
        form.create_draft_from_live_form!
      end

      it "creates draft and live FormDocuments" do
        task.invoke

        expect(draft_document).to be_present
        expect(live_document).to be_present
      end

      it "ensures the live FormDocument matches the live version and the draft matches the current form content" do
        form.update!(submission_email: "new_draft_submission_email@example.com")

        task.invoke

        expect(draft_document).to have_attributes(content: hash_including("submission_email" => "new_draft_submission_email@example.com"))
        expect(live_document).to have_attributes(content: hash_including("submission_email" => "original_submission_email@example.com"))
      end

      include_examples "does not change FormDocuments when invoked twice"

      it "removes any archived FormDocuments" do
        create :form_document, form_id: form.id, tag: "archived"

        task.invoke

        expect(archived_document).to be_nil
      end
    end

    context "when the form is draft" do
      let!(:form) { create :form }

      it "ensures there is a draft FormDocument" do
        task.invoke
        expect(draft_document).to be_present
      end

      it "removes any archived and live FormDocuments" do
        create :form_document, form_id: form.id, tag: "archived"
        create :form_document, form_id: form.id, tag: "live"

        expect {
          task.invoke
        }.to change {
          Api::V2::FormDocument.where(form_id: form.id, tag: %w[live archived]).count
        }.from(2).to(0)
      end

      include_examples "does not change FormDocuments when invoked twice"
    end

    context "when the form is archived" do
      let(:form) { create :form, :ready_for_live }

      before do
        create_live_form(form)
        form.archived!
      end

      it "ensures there an archived FormDocument" do
        task.invoke
        expect(archived_document).to be_present
      end

      it "removes existing live FormDocument" do
        create(:form_document, form_id: form.id, tag: "live")

        expect {
          task.invoke
        }.to change {
          Api::V2::FormDocument.where(form_id: form.id, tag: "live").count
        }.from(1).to(0)
      end

      include_examples "does not change FormDocuments when invoked twice"
    end

    context "when the form is archived with draft" do
      let(:form) { create :form, :ready_for_live }

      before do
        create_live_form(form)
        form.archived!
        form.create_draft_from_archived_form!
      end

      it "ensures there is draft and archived FormDocument which match the Form" do
        task.invoke

        [archived_document, draft_document].each do |doc|
          expect(doc.content["updated_at"]).to eq(form.snapshot["updated_at"])
        end
      end

      it "removes any live FormDocuments" do
        create(:form_document, form_id: form.id, tag: "live")

        expect {
          task.invoke
        }.to change {
          Api::V2::FormDocument.where(form_id: form.id, tag: "live").count
        }.from(1).to(0)
      end

      include_examples "does not change FormDocuments when invoked twice"
    end
  end
end

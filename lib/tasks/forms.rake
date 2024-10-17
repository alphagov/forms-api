namespace :forms do
  desc "Sets the external_id for all forms to their id"
  task set_external_ids: :environment do
    puts "setting external_id for each form to their id"

    Form.find_each { |form| form.update_column(:external_id, form.id) }

    puts "external_id has been set for each form to their id"
  end

  desc "Set submission_type to email_with_csv"
  task :set_submission_type_to_email_with_csv, %i[form_id] => :environment do |_, args|
    usage_message = "usage: rake forms:set_submission_type_to_email_with_csv[<form_id>]".freeze
    abort usage_message if args[:form_id].blank?

    Rails.logger.info("setting submission_type to email_with_csv for form: #{args[:form_id]}")

    form = Form.find(args[:form_id])
    form.email_with_csv!

    made_live_form = form.made_live_forms.last

    if made_live_form.present?
      form_blob = JSON.parse(made_live_form.json_form_blob, symbolize_names: true)

      form_blob[:submission_type] = "email_with_csv"

      made_live_form.update!(json_form_blob: form_blob.to_json)
    end

    Rails.logger.info("set submission_type to email_with_csv for form: #{args[:form_id]}")
  end

  desc "Synchronise FormDocuments with Forms"
  task synchronise_form_documents: :environment do
    Rails.logger.info "forms:synchronise_form_documents starting"

    Rails.logger.info({ pre_synchronise_form_documents: summarise_form_documents })

    Form.find_each do |form|
      Api::V2::FormDocumentSyncService.new.synchronize_form(form)
    end

    Rails.logger.info({ post_synchronise_form_documents: summarise_form_documents })
    Rails.logger.info "forms:synchronise_form_documents finished"
  end

  desc "Synchronise FormDocuments with Forms dry run"
  task synchronise_form_documents_dry_run: :environment do
    Rails.logger.info "forms:synchronise_form_documents_dry_run starting"

    Rails.logger.info({ pre_synchronise_form_documents_dry_run: summarise_form_documents })

    ActiveRecord::Base.transaction do
      Rails.logger.info "forms:synchronise_form_documents_dry_run starting"
      Form.find_each do |form|
        Api::V2::FormDocumentSyncService.new.synchronize_form(form)
      end

      Rails.logger.info({ post_synchronise_form_documents_dry_run: summarise_form_documents })

      raise ActiveRecord::Rollback
    end

    Rails.logger.info "forms:synchronise_form_documents_dry_run finished"
  end

  desc "Summarise FormDocuments"
  task summarise_form_documents: :environment do
    Rails.logger.info({ summarise_form_documents: })
  end
end

def summarise_form_documents
  form_counts = Form.all.group(:state).count
  form_document_counts = Api::V2::FormDocument.all.group(:tag).count

  { form_summary: { form_counts:, form_document_counts: } }
end

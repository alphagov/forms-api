namespace :forms do
  desc "Sets the external_id for all forms to their id"
  task set_external_ids: :environment do
    puts "setting external_id for each form to their id"

    Form.find_each { |form| form.update_column(:external_id, form.id) }

    puts "external_id has been set for each form to their id"
  end

  desc "Set submission_type to email"
  task :set_submission_type_to_email, %i[form_id] => :environment do |_, args|
    usage_message = "usage: rake forms:set_submission_type_to_email[<form_id>]".freeze
    abort usage_message if args[:form_id].blank?

    set_submission_type("email", args[:form_id])
  end

  desc "Set submission_type to email_with_csv"
  task :set_submission_type_to_email_with_csv, %i[form_id] => :environment do |_, args|
    usage_message = "usage: rake forms:set_submission_type_to_email_with_csv[<form_id>]".freeze
    abort usage_message if args[:form_id].blank?

    set_submission_type("email_with_csv", args[:form_id])
  end

  desc "Set submission_type to s3"
  task :set_submission_type_to_s3, %i[form_id s3_bucket_name] => :environment do |_, args|
    usage_message = "usage: rake forms:set_submission_type_to_s3[<form_id>, <s3_bucket_name>]".freeze
    abort usage_message if args[:form_id].blank?
    abort usage_message if args[:s3_bucket_name].blank?

    Rails.logger.info("setting submission_type to s3 and s3_bucket_name to #{args[:s3_bucket_name]}for form: #{args[:form_id]}")
    form = Form.find(args[:form_id])
    form.submission_type = "s3"
    form.s3_bucket_name = args[:s3_bucket_name]
    form.save!

    made_live_form = form.made_live_forms.last
    if made_live_form.present?
      form_blob = JSON.parse(made_live_form.json_form_blob, symbolize_names: true)

      form_blob[:submission_type] = "s3"
      form_blob[:s3_bucket_name] = args[:s3_bucket_name]

      made_live_form.update!(json_form_blob: form_blob.to_json)
    end
    Rails.logger.info("set submission_type to s3 s3_bucket_name to #{args[:s3_bucket_name]} for form: #{args[:form_id]}")
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

def set_submission_type(submission_type, form_id)
  Rails.logger.info("setting submission_type to #{submission_type} for form: #{form_id}")

  form = Form.find(form_id)
  form.submission_type = submission_type
  form.save!

  made_live_form = form.made_live_forms.last

  if made_live_form.present?
    form_blob = JSON.parse(made_live_form.json_form_blob, symbolize_names: true)

    form_blob[:submission_type] = submission_type

    made_live_form.update!(json_form_blob: form_blob.to_json)
  end

  Rails.logger.info("set submission_type to #{submission_type} for form: #{form_id}")
end

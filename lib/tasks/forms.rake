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
end

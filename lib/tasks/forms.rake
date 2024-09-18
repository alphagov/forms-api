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

    puts "setting submission_type to email_with_csv for form: #{args[:form_id]}"

    Form.find(args[:form_id]).email_with_csv!

    puts "set submission_type to email_with_csv for form: #{args[:form_id]}"
  end
end

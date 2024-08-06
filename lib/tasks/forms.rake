namespace :forms do
  desc "Update the organisation that owns a form"
  task :update_organisation, %i[form_id organisation_id] => :environment do |_, args|
    usage_message = "usage: rake forms:update_organisation[<form_id>, <organisation_id>]".freeze
    abort usage_message if args[:form_id].blank? || args[:organisation_id].blank?

    form = Form.find_by(id: args[:form_id])
    abort "Form with ID: #{args[:form_id]} not found" unless form

    form.organisation_id = args[:organisation_id]
    form.save!

    puts "Updated organisation for Form: #{form.id} to be #{args[:organisation_id]}"
  end

  desc "Sets the external_id for all forms to their id"
  task set_external_ids: :environment do
    puts "setting external_id for each form to their id"

    Form.find_each { |form| form.update_column(:external_id, form.id) }

    puts "external_id has been set for each form to their id"
  end
end

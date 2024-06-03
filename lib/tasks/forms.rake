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
end

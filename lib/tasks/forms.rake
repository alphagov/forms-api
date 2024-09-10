namespace :forms do
  desc "Sets the external_id for all forms to their id"
  task set_external_ids: :environment do
    puts "setting external_id for each form to their id"

    Form.find_each { |form| form.update_column(:external_id, form.id) }

    puts "external_id has been set for each form to their id"
  end
end

class AddOrganisationIdToForms < ActiveRecord::Migration[7.0]
  def change
    add_column :forms, :organisation_id, :bigint
  end
end

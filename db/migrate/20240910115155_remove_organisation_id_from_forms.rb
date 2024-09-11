class RemoveOrganisationIdFromForms < ActiveRecord::Migration[7.1]
  def change
    remove_column :forms, :organisation_id, :bigint
  end
end

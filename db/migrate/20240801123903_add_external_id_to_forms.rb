class AddExternalIdToForms < ActiveRecord::Migration[7.1]
  def change
    add_column :forms, :external_id, :string
    add_index :forms, :external_id, unique: true
  end
end

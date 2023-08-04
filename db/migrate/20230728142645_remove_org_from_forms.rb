class RemoveOrgFromForms < ActiveRecord::Migration[7.0]
  def up
    remove_column :forms, :org, :text
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

class AddCreatorIdToForms < ActiveRecord::Migration[7.0]
  def change
    add_column :forms, :creator_id, :bigint
  end
end

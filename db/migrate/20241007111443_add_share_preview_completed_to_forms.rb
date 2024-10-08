class AddSharePreviewCompletedToForms < ActiveRecord::Migration[7.2]
  def change
    add_column :forms, :share_preview_completed, :boolean, null: false, default: false
  end
end

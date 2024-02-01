class RemovePageOrderFromForm < ActiveRecord::Migration[7.1]
  def change
    remove_column :forms, :page_order, :integer
  end
end

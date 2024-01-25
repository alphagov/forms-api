class AddStateColumnToForm < ActiveRecord::Migration[7.1]
  def change
    add_column :forms, :state, :string
  end
end

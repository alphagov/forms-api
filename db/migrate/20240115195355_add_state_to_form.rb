class AddStateToForm < ActiveRecord::Migration[7.1]
  def change
    add_column :forms, :state, :string, default: "draft"
  end
end

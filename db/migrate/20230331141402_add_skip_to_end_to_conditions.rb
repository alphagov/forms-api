class AddSkipToEndToConditions < ActiveRecord::Migration[7.0]
  def change
    add_column :conditions, :skip_to_end, :boolean, default: false
  end
end

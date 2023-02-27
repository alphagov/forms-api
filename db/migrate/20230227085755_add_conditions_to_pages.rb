class AddConditionsToPages < ActiveRecord::Migration[7.0]
  def change
    add_column :pages, :conditions, :text, array: true, default: []
  end
end

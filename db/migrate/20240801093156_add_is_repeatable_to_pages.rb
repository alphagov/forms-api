class AddIsRepeatableToPages < ActiveRecord::Migration[7.1]
  def change
    add_column :pages, :is_repeatable, :boolean, null: false, default: false
  end
end

class CreateConditionsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :conditions do |t|
      t.references :check_page
      t.references :routing_page
      t.references :goto_page
      t.string :answer_value
      t.timestamps
    end
  end
end

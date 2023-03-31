class CreateConditionsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :conditions do |t|
      t.references :check_page, comment: "The question page this condition looks at to compare answers"
      t.references :routing_page, comment: "The question page at which this conditional route takes place"
      t.references :goto_page, comment: "The question page which this conditions will skip forwards to"
      t.string :answer_value
      t.timestamps
    end
  end
end

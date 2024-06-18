class AddFormToSteps < ActiveRecord::Migration[7.1]
  def change
    add_reference :steps, :form, foreign_key: true
  end
end

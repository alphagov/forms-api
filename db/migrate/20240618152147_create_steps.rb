class CreateSteps < ActiveRecord::Migration[7.1]
  def change
    create_table :steps do |t|
      t.references :positionable, polymorphic: true, null: false
      t.references :next_step, index: true, foreign_key: { to_table: :steps }
      t.integer :position
      t.references :parent_question_set, index: true, foreign_key: { to_table: :question_sets }

      t.timestamps
    end
  end
end

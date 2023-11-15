class CreatePages < ActiveRecord::Migration[7.0]
  def change
    create_table :pages do |t|
      t.text :question_text
      t.text :question_short_name
      t.text :hint_text
      t.text :answer_type
      t.integer :next_page
      t.boolean :is_optional
      t.jsonb :answer_settings

      t.timestamps
    end

    add_reference :pages, :form, foreign_key: true
  end
end

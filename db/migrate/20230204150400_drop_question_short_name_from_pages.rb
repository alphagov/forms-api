class DropQuestionShortNameFromPages < ActiveRecord::Migration[7.0]
  def change
    remove_column :pages, :question_short_name, :text
  end
end

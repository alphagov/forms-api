class CreatePagesQuestionTextTranslationsForMobilityColumnBackend < ActiveRecord::Migration[8.0]
  def change
    add_column :pages, :question_text_en, :text
    add_column :pages, :question_text_cy, :text
  end
end

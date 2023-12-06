class RemoveWhatHappensNextTextFromForms < ActiveRecord::Migration[7.0]
  def change
    remove_column :forms, :what_happens_next_text, :text
  end
end

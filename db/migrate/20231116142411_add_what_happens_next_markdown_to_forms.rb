class AddWhatHappensNextMarkdownToForms < ActiveRecord::Migration[7.0]
  def change
    add_column :forms, :what_happens_next_markdown, :text

    reversible do |direction|
      MadeLiveForm.find_each do |made_live_form|
        form_blob = JSON.parse(made_live_form.json_form_blob, symbolize_names: true)

        direction.up do
          form_blob[:what_happens_next_markdown] = nil
        end
        direction.down do
          form_blob.delete(:what_happens_next_markdown)
        end

        made_live_form.update!(json_form_blob: form_blob.to_json)
      end
    end
  end
end

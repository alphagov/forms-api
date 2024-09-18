class AddSubmissionTypeToMadeLiveForms < ActiveRecord::Migration[7.1]
  class MadeLiveForm < ApplicationRecord
    self.table_name = :made_live_forms
  end

  def change
    reversible do |direction|
      MadeLiveForm.find_each do |made_live_form|
        form_blob = JSON.parse(made_live_form.json_form_blob, symbolize_names: true)

        direction.up do
          form_blob[:submission_type] = "email"
        end
        direction.down do
          form_blob.delete(:submission_type)
        end

        made_live_form.update!(json_form_blob: form_blob.to_json)
      end
    end
  end
end

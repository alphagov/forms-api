class CreateMadeLiveForms < ActiveRecord::Migration[7.0]
  def change
    create_table :made_live_forms do |t|
      t.references :form, index: true, foreign_key: true
      t.json :json_form_blob

      t.timestamps
    end
  end
end

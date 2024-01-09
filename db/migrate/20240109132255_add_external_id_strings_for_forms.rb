class AddExternalIdStringsForForms < ActiveRecord::Migration[7.1]
  def change
    reversible do |direction|
      direction.up do
        Form.all.each do |form|
          loop do
            proposed_id = SecureRandom.uuid[0, 8]
            form.external_id = proposed_id
            break unless Form.where(external_id: proposed_id).exists?
          end

          form.save
        end
      end

      direction.down do
        Form.update_all(external_id: nil)
      end
      
      MadeLiveForm.find_each do |made_live_form|
        form_blob = JSON.parse(made_live_form.json_form_blob, symbolize_names: true)

        direction.up do
          form_blob[:external_id] = made_live_form.form.external_id
        end
        
        direction.down do
          form_blob.delete(:external_id)
        end

        made_live_form.update!(json_form_blob: form_blob.to_json)
      end
    end
  end
end

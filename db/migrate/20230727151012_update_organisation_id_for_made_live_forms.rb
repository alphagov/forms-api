class UpdateOrganisationIdForMadeLiveForms < ActiveRecord::Migration[7.0]
  def change
    reversible do |direction|
      Form.find_each do |form|
        if form.made_live_forms.present?
          made_live_form = form.made_live_forms.last
          form_blob = JSON.parse(made_live_form.json_form_blob, symbolize_names: true)

          direction.up do
            form_blob[:organisation_id] = form.organisation_id
            form_blob.delete(:org)
          end
          direction.down do
            form_blob[:org] = form.org
            form_blob.delete(:organisation_id)
          end

          made_live_form.update!(json_form_blob: form_blob.to_json)
        end
      end
    end
  end
end

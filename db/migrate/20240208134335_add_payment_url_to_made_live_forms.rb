class AddPaymentUrlToMadeLiveForms < ActiveRecord::Migration[7.1]
  def change
    reversible do |direction|
      MadeLiveForm.find_each do |made_live_form|
        form_blob = JSON.parse(made_live_form.json_form_blob, symbolize_names: true)

        direction.up do
          form_blob[:payment_url] = nil
        end
        direction.down do
          form_blob.delete(:payment_url)
        end

        made_live_form.update!(json_form_blob: form_blob.to_json)
      end
    end
  end
end

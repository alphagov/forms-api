class AddInitialMadeLiveForms < ActiveRecord::Migration[7.0]
  def up
    Form.where.not(live_at: nil).find_each do |form|
      # Form creators may have made changes to their form after making it live.
      # In future changes will need to be made live separately, and the live
      # version of a form will always have updated_at equal to live_at.
      # To avoid any forwards compatibility issues, let's enforce that now.
      live_at = form.updated_at
      form.live_at = live_at

      made_live_form = form.to_json(include: [:pages])
      form.restore_attributes # don't save change to original form object

      form.made_live_forms.create!(json_form_blob: made_live_form, created_at: live_at)
    end
  end

  def down
    MadeLiveForm.delete_all
  end
end

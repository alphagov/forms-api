class RemoveLiveAtFromForms < ActiveRecord::Migration[7.0]
  def up
    remove_column :forms, :live_at, :datetime
  end

  def down
    add_column :forms, :live_at, :datetime

    Form.find_each do |form|
      if form.made_live_forms.present?
        form.update!(live_at: form.made_live_forms.last.created_at)
      end
    end
  end
end

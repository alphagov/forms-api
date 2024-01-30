class SetExistingFormState < ActiveRecord::Migration[7.1]
  def up
    Form.find_each do |form|
      state = if form.has_live_version
                if form.has_draft_version
                  :live_with_draft
                else
                  :live
                end
              else
                :draft
              end

      form.update_column(:state, state)
    end
  end

  def down
    Form.find_each do |form|
      form.update_column(:state, nil)
    end
  end
end

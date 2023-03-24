class UpdateLiveAtDateTimes < ActiveRecord::Migration[7.0]
  def up
    Form.where.not(live_at: nil).find_each do |form|
      form.made_live_forms.last.update!(created_at: form.live_at)
    end
  end
end

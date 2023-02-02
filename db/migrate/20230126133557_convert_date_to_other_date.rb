class ConvertDateToOtherDate < ActiveRecord::Migration[7.0]
  def up
    Page.where(answer_type: "date", answer_settings: nil).update_all(answer_settings: { input_type: "other_date" })
  end
end

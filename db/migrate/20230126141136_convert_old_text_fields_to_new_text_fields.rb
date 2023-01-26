class ConvertOldTextFieldsToNewTextFields < ActiveRecord::Migration[7.0]
  def up
    Page.where(answer_type: "single_line", answer_settings: nil).update_all(answer_type: "text", answer_settings: { input_type: "single_line" })
    Page.where(answer_type: "long_text", answer_settings: nil).update_all(answer_type: "text", answer_settings: { input_type: "long_text" })
  end

  def down
    Page.where(answer_type: "text", answer_settings: { input_type: "long_text" }).update_all(answer_type: "long_text", answer_settings: nil)
    Page.where(answer_type: "text", answer_settings: { input_type: "single_line" }).update_all(answer_type: "single_line", answer_settings: nil)
  end
end

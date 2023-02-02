class ConvertOldTextFieldsToNewTextFields < ActiveRecord::Migration[7.0]
  def up
    Page.where(answer_type: "single_line", answer_settings: nil).update_all(answer_type: "text", answer_settings: { input_type: "single_line" })
    Page.where(answer_type: "long_text", answer_settings: nil).update_all(answer_type: "text", answer_settings: { input_type: "long_text" })
  end
end

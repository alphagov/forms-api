require Rails.root.join("db/migrate/20230126141136_convert_old_text_fields_to_new_text_fields.rb")

class Rerun1ConvertOldTextFieldsToNewTextFields < ActiveRecord::Migration[7.0]
  def up
    ConvertOldTextFieldsToNewTextFields.new.up
  end
end

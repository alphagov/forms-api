class ConvertAnswerSettingsFromStringNullToNull < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      UPDATE pages
      SET answer_settings = null
      WHERE answer_settings = 'null';
    SQL
  end
end

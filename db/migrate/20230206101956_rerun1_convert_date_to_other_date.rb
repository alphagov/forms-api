require Rails.root.join("db/migrate/20230126133557_convert_date_to_other_date.rb")

class Rerun1ConvertDateToOtherDate < ActiveRecord::Migration[7.0]
  def up
    ConvertDateToOtherDate.new.up
  end
end

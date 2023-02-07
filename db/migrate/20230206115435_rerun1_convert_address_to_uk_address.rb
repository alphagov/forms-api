require Rails.root.join("db/migrate/20230126135721_convert_address_to_uk_address.rb")

class Rerun1ConvertAddressToUkAddress < ActiveRecord::Migration[7.0]
  def up
    ConvertAddressToUkAddress.new.up
  end
end

class ConvertAddressToUkAddress < ActiveRecord::Migration[7.0]
  def up
    Page.where(answer_type: "address", answer_settings: nil).update_all(answer_settings: { input_type: { uk_address: "true", international_address: "false" } })
  end

  def down
    Page.where(answer_type: "address").update_all(answer_settings: nil)
  end
end

class AddPaymentUrlToForms < ActiveRecord::Migration[7.1]
  def change
    add_column :forms, :payment_url, :string
  end
end

class MakeIsOptionalNonNullable < ActiveRecord::Migration[7.1]
  def change
    change_column_null :pages, :is_optional, false, false
  end
end

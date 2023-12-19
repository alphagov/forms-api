class AddPermissionsToAccessTokens < ActiveRecord::Migration[7.1]
  def change
    add_column :access_tokens, :permissions, :string, default: "all"
  end
end

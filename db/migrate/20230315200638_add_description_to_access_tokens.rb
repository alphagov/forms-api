class AddDescriptionToAccessTokens < ActiveRecord::Migration[7.0]
  def change
    add_column :access_tokens, :description, :string
  end
end

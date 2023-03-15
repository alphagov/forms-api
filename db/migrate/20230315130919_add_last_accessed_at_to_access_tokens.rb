class AddLastAccessedAtToAccessTokens < ActiveRecord::Migration[7.0]
  def change
    add_column :access_tokens, :last_accessed_at, :datetime
  end
end

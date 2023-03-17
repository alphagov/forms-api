class RenameTokenToTokenDigestFromAccessToken < ActiveRecord::Migration[7.0]
  def change
    rename_column :access_tokens, :token, :token_digest
  end
end

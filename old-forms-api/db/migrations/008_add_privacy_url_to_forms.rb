Sequel.migration do
  up do
    add_column :forms, :privacy_policy_url, String
  end
  down do
    drop_column :forms, :privacy_policy_url
  end
end

Sequel.migration do
  up do
    add_column :forms, :support_email, String
    add_column :forms, :support_phone, String
    add_column :forms, :support_url, String
    add_column :forms, :support_url_text, String
  end
  down do
    drop_column :forms, :support_email
    drop_column :forms, :support_phone
    drop_column :forms, :support_url
    drop_column :forms, :support_url_text
  end
end

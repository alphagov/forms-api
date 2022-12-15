Sequel.migration do
  up do
    add_column :forms, :declaration_text, String
  end
  down do
    drop_column :forms, :declaration_text
  end
end

Sequel.migration do
  up do
    add_column :forms, :what_happens_next_text, String
  end
  down do
    drop_column :forms, :what_happens_next_text
  end
end

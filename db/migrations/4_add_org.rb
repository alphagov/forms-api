Sequel.migration do
  up do
    add_column :forms, :org, String
    from(:forms).update(org: "government-digital-service")
  end
  down do
    drop_column :forms, :org
  end
end

Sequel.migration do
  up do
    add_column :pages, :is_optional, TrueClass
  end
  down do
    drop_column :pages, :is_optional
  end
end

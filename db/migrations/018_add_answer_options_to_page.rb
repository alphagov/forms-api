Sequel.migration do
  up do
    add_column :pages, :answer_settings, :jsonb
  end
  down do
    drop_column :pages, :answer_settings
  end
end

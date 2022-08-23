Sequel.migration do
  up do
    rename_column :pages, :next, :next_page
  end

  down do
    rename_column :pages, :next_page, :next
  end
end

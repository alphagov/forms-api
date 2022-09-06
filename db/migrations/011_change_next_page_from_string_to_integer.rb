Sequel.migration do
  up do
    alter_table :pages do
        set_column_type :next_page, Integer, using: 'next_page::integer'
    end
  end

  down do
    alter_table :pages do
        set_column_type :next_page, String
    end
  end
end

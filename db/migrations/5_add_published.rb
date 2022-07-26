require "pry"

Sequel.migration do
  up do
    add_column :forms, :published, :boolean
    from(:forms).update(published: false)
  end
  down do
    drop_column :forms, :published
  end
end

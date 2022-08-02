require "pry"

Sequel.migration do
  up do
    add_column :forms, :created_at, :timestamp
    from(:forms).update(created_at: nil)
    add_column :forms, :published_at, :timestamp
    from(:forms).update(published_at: nil)
    add_column :forms, :updated_at, :timestamp
    from(:forms).update(updated_at: nil)
  end
  down do
    drop_column :forms, :created_at
    drop_column :forms, :published_at
    drop_column :forms, :updated_at
  end
end

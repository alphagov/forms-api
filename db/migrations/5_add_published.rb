require "pry"

Sequel.migration do
  up do
    add_column :forms, :created_at, :timestamp
    from(:forms).update(created_at: nil)
    add_column :forms, :live_at, :timestamp
    from(:forms).update(live_at: nil)
    add_column :forms, :updated_at, :timestamp
    from(:forms).update(updated_at: nil)
  end
  down do
    drop_column :forms, :created_at
    drop_column :forms, :live_at
    drop_column :forms, :updated_at
  end
end

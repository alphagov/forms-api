Sequel.migration do
  up do
    from(:forms).where(created_at: nil).update(
      updated_at: Time.now,
      created_at: Time.now
    )
  end
  down do
    # this is a data migration, no down needed
  end
end

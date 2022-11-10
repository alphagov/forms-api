Sequel.migration do
  up do
    add_column :forms, :declaration_section_completed, TrueClass, default: false

    from(:forms).exclude(live_at: nil).each do |live_form|
      from(:forms).where(id: live_form[:id]).update(declaration_section_completed: true)
    end
  end
  down do
    drop_column :forms, :declaration_section_completed
  end
end

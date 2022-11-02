Sequel.migration do
  up do
    add_column :forms, :question_section_completed, TrueClass, default: false
  end
  down do
    drop_column :forms, :question_section_completed
  end
end

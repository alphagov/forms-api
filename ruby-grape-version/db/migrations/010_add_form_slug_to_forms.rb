Sequel.migration do
  up do
    add_column :forms, :form_slug, String

    forms = from(:forms).all
    forms.each do |form|
      from(:forms).where(id: form[:id]).update(form_slug: form[:name].parameterize)
    end
  end
  down do
    drop_column :forms, :form_slug
  end
end

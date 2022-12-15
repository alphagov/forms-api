Sequel.migration do
  up do
    add_column :forms, :page_order, "integer[]", default: []

    # Before this change, the order of pages is defined by page id, which
    # increases with every new page. Running this update collects the page ids for each
    # form and adds them to the form as an array, in the correct order.
    update_existing = <<~SQL
      UPDATE forms
         SET page_order=pages_id_order
        FROM (SELECT form_id, array_agg(id ORDER BY id) pages_id_order FROM pages GROUP BY form_id) forms_pages
       WHERE forms_pages.form_id=forms.id
    SQL

    run update_existing
  end

  down do
    drop_column :forms, :page_order
  end
end

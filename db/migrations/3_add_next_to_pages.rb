require "pry"

Sequel.migration do
  up do
    add_column :pages, :next, String
    forms = from(:forms).all()
    forms.each do |form| 
      pages = from(:pages).where(form_id: form[:id]).all()

      pages.each_with_index do |page, i|
        from(:pages).where(id: page[:id]).update(next: pages[i + 1][:id]) if i < pages.length - 1
      end
    end 
  end
  down do
    drop_column :pages, :next
  end
end

Sequel.migration do
  up do
    from(:pages).exclude(next: nil).each do |page|
      current_page = from(:pages).where(id: page[:id])

      next_page = from(:pages).where(id: page[:next])

      current_page.update(next: nil) if next_page.get(:form_id) != current_page.get(:form_id)
    end
  end
end

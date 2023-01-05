class UpdatePagesPositionToExistingOrder < ActiveRecord::Migration[7.0]
  def up
    forms_with_pages = Form.where.not(page_order: nil)

    forms_with_pages.each do |form|
      page_order = form.page_order

      page_order.each_with_index do |page, index|
        page = Page.find(page)
        page.update!(position: index + 1)
      end
    end
  end
end

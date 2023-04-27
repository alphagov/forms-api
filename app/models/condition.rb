class Condition < ApplicationRecord
  has_paper_trail

  belongs_to :routing_page, class_name: "Page"
  belongs_to :check_page, class_name: "Page", optional: true
  belongs_to :goto_page, class_name: "Page", optional: true

  has_one :form, through: :routing_page

  def save_and_update_form
    save && form.update!(question_section_completed: false)
  end

  def destroy_and_update_form!
    destroy! && form.update!(question_section_completed: false)
  end

  def validation_errors
    [warning_goto_page_doesnt_exist].compact
  end

  def warning_goto_page_doesnt_exist
    page = form.pages.find_by(id: goto_page_id)
    return nil if page.present?

    { name: "goto_page_doesnt_exist" }
  end

end

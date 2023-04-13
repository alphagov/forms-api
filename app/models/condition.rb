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
end

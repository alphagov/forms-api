class Condition < ApplicationRecord
  has_paper_trail

  belongs_to :routing_page, class_name: "Page"
  belongs_to :check_page, class_name: "Page", optional: true
  belongs_to :goto_page, class_name: "Page", optional: true

  has_one :form, through: :routing_page

  def save_and_update_form
    save!
    form.update!(question_section_completed: false)
    form.draft_new_live_form! if form.live?
    form.create_draft_from_archived_form! if form.archived?
  end

  def destroy_and_update_form!
    destroy! && form.update!(question_section_completed: false)
  end

  def validation_errors
    [
      warning_goto_page_doesnt_exist,
      warning_answer_doesnt_exist,
      warning_routing_to_next_page,
      warning_goto_page_before_check_page,
    ].compact
  end

  def warning_goto_page_doesnt_exist
    # goto_page_id isn't needed if the route is skipping to the end of the form
    return nil if is_check_your_answers?

    page = form.pages.find_by(id: goto_page_id)
    return nil if page.present?

    { name: "goto_page_doesnt_exist" }
  end

  def warning_answer_doesnt_exist
    answer_options = check_page&.answer_settings&.dig("selection_options")&.pluck("name")
    return nil if answer_options.blank? || answer_options.include?(answer_value) || answer_value == :none_of_the_above.to_s && check_page.is_optional?

    { name: "answer_value_doesnt_exist" }
  end

  def warning_routing_to_next_page
    return nil if check_page.nil? || goto_page.nil? && !is_check_your_answers?

    check_page_position = check_page.position
    goto_page_position = is_check_your_answers? ? form.pages.last.position + 1 : goto_page.position

    return { name: "cannot_route_to_next_page" } if goto_page_position == (check_page_position + 1)

    nil
  end

  def warning_goto_page_before_check_page
    return nil if check_page.nil? || goto_page.nil?

    check_page_position = check_page.position
    goto_page_position = goto_page.position

    return { name: "cannot_have_goto_page_before_routing_page" } if goto_page_position < (check_page_position + 1)

    nil
  end

  def is_check_your_answers?
    goto_page.nil? && skip_to_end
  end

  def as_json(options = {})
    super(options.reverse_merge(
      except: [:next_page],
      methods: %i[validation_errors has_routing_errors],
    ))
  end

  def has_routing_errors
    validation_errors.any?
  end
end

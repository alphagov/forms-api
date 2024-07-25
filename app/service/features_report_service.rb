class FeaturesReportService
  def report
    {
      total_live_forms: live_forms.count,
      live_forms_with_answer_type:,
      live_pages_with_answer_type:,
      live_forms_with_payment:,
      live_forms_with_routing:,
    }
  end

private

  def live_forms
    @live_forms ||= Form.all.filter(&:has_live_version)
  end

  def pages_on_live_forms
    @pages_on_live_forms ||= live_forms.flat_map(&:pages)
  end

  def number_of_live_forms_with_answer_type(answer_type)
    live_forms.filter { |form| form.pages.any? { |page| page.answer_type == answer_type } }.count
  end

  def live_forms_with_payment
    live_forms.filter { |form| form.payment_url.present? }.count
  end

  def live_forms_with_routing
    live_forms.filter { |form| form.pages.any? { |page| page.routing_conditions.present? } }.count
  end

  def number_of_live_form_pages_with_answer_type(answer_type)
    pages_on_live_forms.filter { |page| page.answer_type == answer_type }.count
  end

  def live_forms_with_answer_type
    Page::ANSWER_TYPES.to_h { |answer_type| [answer_type.to_sym, number_of_live_forms_with_answer_type(answer_type)] }
  end

  def live_pages_with_answer_type
    Page::ANSWER_TYPES.to_h { |answer_type| [answer_type.to_sym, number_of_live_form_pages_with_answer_type(answer_type)] }
  end
end

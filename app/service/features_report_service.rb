class FeaturesReportService
  def report
    {
      total_live_forms: live_forms.count,
      live_forms_with_answer_type: { name: number_of_live_forms_with_answer_type("name"),
                                     organisation_name: number_of_live_forms_with_answer_type("organisation_name"),
                                     phone_number: number_of_live_forms_with_answer_type("phone_number"),
                                     email: number_of_live_forms_with_answer_type("email"),
                                     address: number_of_live_forms_with_answer_type("address"),
                                     national_insurance_number: number_of_live_forms_with_answer_type("national_insurance_number"),
                                     date: number_of_live_forms_with_answer_type("date"),
                                     number: number_of_live_forms_with_answer_type("number"),
                                     selection: number_of_live_forms_with_answer_type("selection"),
                                     text: number_of_live_forms_with_answer_type("text") },
      live_forms_with_payment:,
      live_forms_with_routing:,
    }
  end

private

  def live_forms
    @live_forms ||= Form.all.filter(&:has_live_version)
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
end

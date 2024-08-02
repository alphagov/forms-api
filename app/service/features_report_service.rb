class FeaturesReportService
  def report
    {
      total_live_forms:,
      live_forms_with_answer_type:,
      live_pages_with_answer_type:,
      live_forms_with_payment:,
      live_forms_with_routing:,
      live_forms_with_add_another_answer:,
    }
  end

private

  def total_live_forms
    Form.where(state: %w[live live_with_draft]).count
  end

  def live_forms_with_payment
    Form.where(state: %w[live live_with_draft]).where.not(payment_url: [nil, ""]).count
  end

  def live_forms_with_routing
    Page.joins(:form).where(forms: { state: %w[live live_with_draft] }).where.associated(:routing_conditions).select("forms.id").distinct.count
  end

  def live_forms_with_answer_type
    Page.joins(:form).where(forms: { state: %w[live live_with_draft] }).select("forms.id,pages.answer_type").distinct.group(:answer_type).count("forms.id").symbolize_keys
  end

  def live_pages_with_answer_type
    Page.joins(:form).where(forms: { state: %w[live live_with_draft] }).group(:answer_type).count.symbolize_keys
  end

  def live_forms_with_add_another_answer
    Page.joins(:form).where(forms: { state: %w[live live_with_draft] }).select("forms.id,pages.is_repeatable").where(pages: { is_repeatable: true }).count("forms.id")
  end
end

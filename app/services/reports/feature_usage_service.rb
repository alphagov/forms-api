class Reports::FeatureUsageService
  def report
    {
      total_live_forms:,
      live_forms_with_answer_type:,
      live_pages_with_answer_type:,
      live_forms_with_payment:,
      live_forms_with_routing:,
      live_forms_with_add_another_answer:,
      live_forms_with_csv_submission_enabled:,
      all_forms_with_add_another_answer:,
    }
  end

private

  # NOTE: all of these methods currently query the Form table rather than the MadeLiveForm table.
  # This means that they may include updates which have been made to forms since they were made live.
  # As a result, the figures in the report may vary slightly from the actual live figures.
  # TODO: rewrite the queries to only check the content of live forms

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

  def live_forms_with_csv_submission_enabled
    Form.where(state: %w[live live_with_draft]).where(submission_type: "email_with_csv").count
  end

  def all_forms_with_add_another_answer
    forms = Form.includes(:pages).where(pages: { is_repeatable: true })

    forms.map do |form|
      {
        form_id: form.id,
        name: form.name,
        state: form.state,
        repeatable_pages: form.pages.map { |page| { page_id: page.id, question_text: page.question_text } if page.is_repeatable },
      }
    end
  end
end

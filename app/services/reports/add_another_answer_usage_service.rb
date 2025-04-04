class Reports::AddAnotherAnswerUsageService
  def add_another_answer_forms
    forms = Form.includes(:pages)
                .where(pages: { is_repeatable: true })
                .map(&method(:form_data))

    # adding the count even though forms-admin doesn't use it as ActiveResource doesn't like parsing JSON with a single root key
    { forms:, count: forms.length }
  end

private

  def form_data(form)
    {
      form_id: form.id,
      name: form.name,
      state: form.state,
      repeatable_pages: form.pages.map { |page| { page_id: page.id, question_text: page.question_text } if page.is_repeatable },
    }
  end
end

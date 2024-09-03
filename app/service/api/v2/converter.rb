class Api::V2::Converter
  def to_api_v2_form_document(form_snapshot)
    form_snapshot = form_snapshot.deep_dup

    form_snapshot.delete("id")

    pages = form_snapshot.delete("pages")
    form_snapshot["steps"] = pages.map { |page| to_api_v2_step(page) }

    form_snapshot
  end

private

  def to_api_v2_step(page)
    step = {
      "id" => page["id"],
      "position" => page["position"],
      "next_step_id" => page["next_page"],
    }
    if page["question_text"].present?
      step["type"] = "question_page"
      step["data"] = page.slice(*%w[question_text hint_text answer_type is_optional answer_settings page_heading guidance_markdown is_repeatable])
    end
    step["routing_conditions"] = page.fetch("routing_conditions", [])
    step
  end
end

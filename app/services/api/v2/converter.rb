class Api::V2::Converter
  def to_api_v2_form_document(form_snapshot, form_id: nil)
    form_snapshot = form_snapshot.deep_dup

    form_snapshot.delete("id")
    form_snapshot = { "form_id" => form_id, **form_snapshot } if form_id

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
      step["data"] = page.slice(*%w[hint_text answer_type is_optional answer_settings page_heading guidance_markdown is_repeatable])
      step["data"]["question_text"] = question_text(page)
      step["data"]["page_heading"] = page_heading(page)
      step["data"]["guidance_markdown"] = guidance_markdown(page)
    end
    step["routing_conditions"] = page.fetch("routing_conditions", [])
    step
  end
end

def question_text(page)
  return page["question_text_cy"] if I18n.locale == :cy && page["question_text_cy"]

  page["question_text_en"] || page["question_text"]
end

def page_heading(page)
  return page["page_heading_cy"] if I18n.locale == :cy && page["page_heading_cy"]

  page["page_heading_en"] || page["page_heading"]
end

def guidance_markdown(page)
  return page["guidance_markdown_cy"] if I18n.locale == :cy && page["guidance_markdown_cy"]

  page["guidance_markdown_en"] || page["guidance_markdown"]
end

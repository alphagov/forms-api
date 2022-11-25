class Domain::Page
  attr_accessor :id,
                :form_id,
                :question_text,
                :question_short_name,
                :hint_text,
                :answer_type,
                :next_page,
                :is_optional,
                :answer_settings

  def to_h
    {
      id:,
      form_id:,
      question_text:,
      question_short_name:,
      hint_text:,
      answer_type:,
      next_page:,
      is_optional:,
      answer_settings:
    }
  end
end

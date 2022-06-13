class Repositories::PagesRepository
  def initialize(database)
    @database = database
  end

  def create(form_id, question_text, question_short_name, hint_text, answer_type)
    id = @database[:pages].insert(
      form_id: form_id,
      question_text: question_text, 
      question_short_name: question_short_name, 
      hint_text: hint_text, 
      answer_type: answer_type
    )
  end
end

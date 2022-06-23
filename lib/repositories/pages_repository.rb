class Repositories::PagesRepository
  def initialize(database)
    @database = database
  end

  def create(page)
    @database[:pages].insert(
      form_id: page.form_id,
      question_text: page.question_text,
      question_short_name: page.question_short_name,
      hint_text: page.hint_text,
      answer_type: page.answer_type,
      next: page.next
    )
  end

  def get(page_id)
    found_page = @database[:pages].where(id: page_id).all.last

    page_from_data(found_page)
  end

  def update(page)
    @database[:pages].where(id: page.id).update(
      question_text: page.question_text,
      question_short_name: page.question_short_name,
      hint_text: page.hint_text,
      answer_type: page.answer_type,
      next: page.next
    )
  end

  def delete(page_id)
    @database[:pages].where(id: page_id).delete
  end

  def get_pages_in_form(form_id)
    @database[:pages].where(form_id:).all.map { |p| page_from_data(p) }
  end

  private

  def page_from_data(page_data)
    Domain::Page.new.tap do |page|
      page.id = page_data[:id]
      page.form_id = page_data[:form_id]
      page.question_text = page_data[:question_text]
      page.question_short_name = page_data[:question_short_name]
      page.hint_text = page_data[:hint_text]
      page.answer_type = page_data[:answer_type]
      page.next = page_data[:next]
    end
  end
end

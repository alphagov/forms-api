class Repositories::PagesRepository
  def initialize(database)
    @database = database
  end

  def create(page)
    # Append the page to the end of the page linked list this means that we
    # have to set the next value of the page which was last (if there are any
    # pages) this page would have had next = null. We insert the page then set
    # the value in a single transaction
    @database.transaction(isolation: :serializable) do
      new_page_id = @database[:pages].insert(
        form_id: page.form_id,
        question_text: page.question_text,
        question_short_name: page.question_short_name,
        hint_text: page.hint_text,
        answer_type: page.answer_type
      )

      @database[:pages].where(form_id: page.form_id, next: nil).exclude(id: new_page_id).update(next: new_page_id)

      new_page_id
    end
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
    @database.transaction(isolation: :serializable) do
      pages = @database[:pages]

      # get the next value of our page and update any pages which pointed to us
      # to that instead
      next_page_id = pages.where(id: page_id).get(:next)
      pages.where(next: page_id.to_s).update(next: next_page_id)
      pages.where(id: page_id).delete
    end
  end

  def get_pages_in_form(form_id)
    @database[:pages].where(form_id:).order(:id).all.map { |p| page_from_data(p) }
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

class Repositories::PagesRepository
  def initialize(database)
    @database = database
  end

  # Create a new page at the end of the forms page_order array
  def create(page)
    @database.transaction(isolation: :serializable) do
      new_page_id = @database[:pages].insert(
        form_id: page.form_id,
        question_text: page.question_text,
        question_short_name: page.question_short_name,
        hint_text: page.hint_text,
        answer_type: page.answer_type,
        is_optional: page.is_optional,
        answer_settings: page.answer_settings
      )

      # Keep updating the old next_page in case we need to roll back
      @database[:pages].where(form_id: page.form_id, next_page: nil).exclude(id: new_page_id).update(next_page: new_page_id)

      @database[:forms].where(id: page.form_id).update(page_order: @database["SELECT array_append(page_order,?) from forms where id=?", new_page_id, page.form_id])
      @database[:forms].where(id: page.form_id).update(question_section_completed: false)

      new_page_id
    end
  end

  # Return a single page, given a page_id
  def get(page_id)
    # Find the page, and use the pages form_id to find the pages next_page
    single_page_with_next = <<~SQL
      SELECT p.*,
             f.page_order[array_position(f.page_order, p.id::int) + 1] AS calulated_next_page
        FROM pages p
        JOIN forms f
          ON p.form_id=f.id WHERE p.id=?
    SQL
    found_page = @database[single_page_with_next, page_id].all.last
    page_from_data(found_page)
  end

  def update(page)
    # Updating a page cannot change the order of pages in a form, so we don't
    # need to perform any extra steps
    @database[:pages].where(id: page.id).update(
      question_text: page.question_text,
      question_short_name: page.question_short_name,
      hint_text: page.hint_text,
      answer_type: page.answer_type,
      is_optional: page.is_optional,
      answer_settings: page.answer_settings
    )

    @database[:forms].where(id: page.form_id).update(question_section_completed: false)
  end

  def delete(page_id)
    delete_count = 0
    @database.transaction(isolation: :serializable) do
      # delete the page, then use the form_id of the deleted page to remove the
      # page_id from the forms page_order array
      @database[:pages].returning(:form_id).where(id: page_id).delete do |page_hash|
        delete_count += 1
        @database[:forms].where(id: page_hash[:form_id]).update(page_order: @database["SELECT array_remove(page_order,?) FROM forms WHERE id=?", page_id, page_hash[:form_id]])
        # Keep updating the old next_page in case we need to roll back
        @database[:pages].where(next_page: page_id).update(next_page: page_hash[:next_page])
      end
    end
    delete_count
  end

  # Return the pages in form, listed in an array in order. The first page in
  # the array will be the start_page. For each page, calculate the column of next_page.
  def get_pages_in_form(form_id)
    ordered_pages_with_next = <<~SQL
      SELECT p.*,
             f.page_order[array_position(f.page_order, p.id::int) + 1] AS calulated_next_page
      FROM forms f,
           unnest(f.page_order) WITH ORDINALITY page(id, nr)
      JOIN pages p
        ON p.id=page.id
      WHERE f.id = ?
      ORDER BY page.nr
    SQL

    pages_in_order = @database.fetch(ordered_pages_with_next, form_id).all
    pages_in_order.map { |p| page_from_data(p) }
  end

  def move_page_down(form_id, page_id)
    @database.transaction(isolation: :serializable) do
      page_order = @database[:forms].where(id: form_id).get(:page_order)
      @database[:forms].where(id: form_id).update(page_order: Sequel.pg_array(move_item_down(page_id, page_order)))
    end
  end

  def move_page_up(form_id, page_id)
    @database.transaction(isolation: :serializable) do
      page_order = @database[:forms].where(id: form_id).get(:page_order)
      @database[:forms].where(id: form_id).update(page_order: Sequel.pg_array(move_item_up(page_id, page_order)))
    end
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
      page.next_page = page_data[:calulated_next_page]
      page.is_optional = page_data[:is_optional]
      page.answer_settings = page_data[:answer_settings]
    end
  end

  # Find an array element by value and move it one position towards the end of
  # the array. If the item is the last element of the array or the array does not
  # contain the element, return the array unchanged.
  # move_item_down(2, [1,2,3]) -> [1,3,2]
  def move_item_down(value, arr)
    i = arr.index(value)
    return arr if (i == arr.length - 1) || i.nil?

    arr.insert(i + 1, arr.delete_at(i))
  end

  # Find an array element by value and move it one position towards the start of
  # the array. If the item is the first element of the array or the array does not
  # contain the element, return the array unchanged.
  # move_item_up(2, [1,2,3]) -> [2,1,3]
  def move_item_up(value, arr)
    i = arr.index(value)
    return arr if i.zero? || i.nil?

    arr.insert(i - 1, arr.delete_at(i))
  end
end

describe Repositories::PagesRepository do
  include_context "with database"

  let(:subject) { described_class.new(database) }
  let(:form_id) do
    repository = Repositories::FormsRepository.new(@database)
    repository.create("Form 1", "email", "org")
  end
  let(:another_form_id) do
    repository = Repositories::FormsRepository.new(@database)
    repository.create("Form 2", "email", "org")
  end
  let(:page) do
    Domain::Page.new.tap do |page|
      page.form_id = form_id
      page.question_text = "question_text"
      page.question_short_name = "question_short_name"
      page.hint_text = "hint_text"
      page.answer_type = "answer_type"
      page.next_page = nil
      page.is_optional = nil
      page.answer_settings = nil
    end
  end

  let(:page_for_another_form) do
    Domain::Page.new.tap do |page|
      page.form_id = another_form_id
      page.question_text = "question_text"
      page.question_short_name = "question_short_name"
      page.hint_text = "hint_text"
      page.answer_type = "answer_type"
      page.next_page = nil
      page.is_optional = nil
      page.answer_settings = nil
    end
  end

  context "creating a new page" do
    it "creates a single page" do
      first_page_result = subject.create(page)

      created_page = database[:pages].where(id: first_page_result).all.last

      expect(created_page[:question_text]).to eq("question_text")
      expect(created_page[:question_short_name]).to eq("question_short_name")
      expect(created_page[:hint_text]).to eq("hint_text")
      expect(created_page[:answer_type]).to eq("answer_type")
      expect(created_page[:form_id]).to eq(form_id)
      expect(created_page[:next_page]).to be_nil
      expect(created_page[:is_optional]).to be_nil
      expect(created_page[:answer_settings]).to be_nil
    end

    it "resets forms 'question_section_completed' value" do
      database[:forms].where(id: form_id).update(question_section_completed: true)
      subject.create(page)

      repository = Repositories::FormsRepository.new(@database)
      form = repository.get(form_id)
      expect(form[:question_section_completed]).to be false
    end
  end

  context "create a second page for the same form" do
    it "should set the previous next_page attribute to the new page id" do
      first_page_id = subject.create(page)
      second_page_id = subject.create(page)

      first_page_result = subject.get(first_page_id)

      expect(first_page_result.next_page).to eq(second_page_id)

      # Check legacy page ordering code
      expect(first_page_result.next_page).to eq(second_page_id)
    end

    it "should not update another form pages next_page attribute" do
      another_form_page_id = subject.create(page_for_another_form)
      first_page_id = subject.create(page)
      second_page_id = subject.create(page)

      first_page_result = subject.get(first_page_id)
      another_form_page_result = subject.get(another_form_page_id)

      expect(first_page_result.next_page).to eq(second_page_id)
      expect(another_form_page_result.next_page).to be_nil

      # Check legacy page ordering code
      expect(first_page_result.next_page).to eq(second_page_id)
      expect(another_form_page_result.next_page).to be_nil
    end
  end

  context "getting a page" do
    it "gets a single page" do
      page_id = subject.create(page)
      found_page = subject.get(page_id)
      expect(found_page.question_text).to eq("question_text")
      expect(found_page.question_short_name).to eq("question_short_name")
      expect(found_page.hint_text).to eq("hint_text")
      expect(found_page.next_page).to eq(nil)
      expect(found_page.answer_type).to eq("answer_type")
      expect(found_page.form_id).to eq(form_id)
      expect(found_page.is_optional).to be_nil
      expect(found_page.answer_settings).to be_nil
    end

    it "gets a single page with correct next_page value" do
      page_id = subject.create(page)
      page_id2 = subject.create(page)
      found_page = subject.get(page_id)
      expect(found_page.question_text).to eq("question_text")
      expect(found_page.question_short_name).to eq("question_short_name")
      expect(found_page.hint_text).to eq("hint_text")
      expect(found_page.next_page).to eq(page_id2)
      expect(found_page.answer_type).to eq("answer_type")
      expect(found_page.form_id).to eq(form_id)
      expect(found_page.is_optional).to be_nil
    end
  end

  describe "#get_pages_in_form" do
    it "gets a multiple pages with correct next_page values in the correct order" do
      page_id1 = subject.create(page)
      page_id2 = subject.create(page)
      page_id3 = subject.create(page)

      found_pages = subject.get_pages_in_form(form_id)

      expect(found_pages.length).to eq(3)
      expect(found_pages.map(&:id)).to eq([page_id1, page_id2, page_id3])
      expect(found_pages[0].question_text).to eq("question_text")
      expect(found_pages[0].question_short_name).to eq("question_short_name")
      expect(found_pages[0].hint_text).to eq("hint_text")
      expect(found_pages[0].next_page).to eq(page_id2)
      expect(found_pages[0].answer_type).to eq("answer_type")
      expect(found_pages[0].form_id).to eq(form_id)
      expect(found_pages[0].is_optional).to be_nil
    end
  end

  context "updating a page" do
    it "updates a page" do
      page_id = subject.create(page)
      page.id = page_id
      page.question_text = "question_text2"
      page.question_short_name = "question_short_name2"
      page.hint_text = "hint_text2"
      page.answer_type = "answer_type2"
      page.is_optional = true
      page.answer_settings = { only_one_option: true, selection_options: [{ name: "option 1" }] }.to_json
      update_result = subject.update(page)

      page = subject.get(page_id)
      expect(update_result).to eq(1)
      expect(page.question_text).to eq("question_text2")
      expect(page.question_short_name).to eq("question_short_name2")
      expect(page.hint_text).to eq("hint_text2")
      expect(page.answer_type).to eq("answer_type2")
      expect(page.next_page).to eq(nil)
      expect(page.form_id).to eq(form_id)
      expect(page.is_optional).to be true
      expect(page.answer_settings).to eq({ "only_one_option" => true, "selection_options" => [{ "name" => "option 1" }] })

      repository = Repositories::FormsRepository.new(@database)
      form = repository.get(form_id)
      expect(form[:created_at].to_i).to be_within(0).of(Time.now.to_i)
      expect(form[:updated_at].to_i).to be_within(0).of(Time.now.to_i)
    end
  end
  context "updating a page, resets form attributes" do
    it "resets forms 'question_section_completed' value" do
      database[:forms].where(id: form_id).update(question_section_completed: true)
      subject.create(page)
      subject.update(page)

      repository = Repositories::FormsRepository.new(@database)
      form = repository.get(form_id)
      expect(form[:question_section_completed]).to be false
    end
  end

  context "deleting a page which exists" do
    it "deletes a page" do
      page_id = subject.create(page)
      result = subject.delete(page_id)

      expect(result).to eq(1)
    end

    it "updates other page next_page values" do
      first_page_id = subject.create(page)
      second_page_id = subject.create(page)
      third_page_id = subject.create(page)

      result = subject.delete(second_page_id)

      first_page_next = subject.get(first_page_id).next_page
      expect(first_page_next).to eq(third_page_id)

      expect(result).to eq(1)
    end

    it "updates other page next_page values" do
      first_page_id = subject.create(page)
      second_page_id = subject.create(page)
      third_page_id = subject.create(page)

      result = subject.delete(second_page_id)

      first_page_next = subject.get(first_page_id).next_page
      expect(first_page_next).to eq(third_page_id)
      expect(result).to eq(1)
    end
  end

  context "deleting a page which does not exist" do
    it "does not update other page next_page values" do
      first_page_id = subject.create(page)
      second_page_id = subject.create(page)
      third_page_id = subject.create(page)

      result = subject.delete(999)

      first_page_next = subject.get(first_page_id).next_page
      second_page_next = subject.get(second_page_id).next_page
      third_page_next = subject.get(third_page_id).next_page

      expect(result).to eq(0)
      expect(first_page_next).to eq(second_page_id)
      expect(second_page_next).to eq(third_page_id)
      expect(third_page_next).to eq(nil)

      # Expect legacy next_page to still be updated and working
      legacy_first_page_next = database[:pages].where(id: first_page_id).get(:next_page)
      legacy_second_page_next = database[:pages].where(id: second_page_id).get(:next_page)
      legacy_third_page_next = database[:pages].where(id: third_page_id).get(:next_page)

      expect(legacy_first_page_next).to eq(second_page_id)
      expect(legacy_second_page_next).to eq(third_page_id)
      expect(legacy_third_page_next).to eq(nil)
    end
  end

  context "getting pages for a form" do
    it "gets pages for a form" do
      page_id1 = subject.create(page)
      page_id2 = subject.create(page)
      pages = subject.get_pages_in_form(form_id)
      expect(pages.length).to eq(2)
      expect(pages[0].id).to eq(page_id1)
      expect(pages[1].id).to eq(page_id2)
    end
  end

  describe "#move_page_down" do
    it "with a single page doesn't change the next_page id" do
      page_id1 = subject.create(page)

      subject.move_page_down(form_id, page_id1)
      first_page_next = subject.get(page_id1).next_page

      expect(first_page_next).to eq(nil)
      expect(subject.get_pages_in_form(form_id).map(&:id)).to eq([page_id1])
    end

    it "with two pages, moving the first changes the next_page id of both pages" do
      page_id1 = subject.create(page)
      page_id2 = subject.create(page)

      expect(subject.get(page_id1).next_page).to eq(page_id2)
      expect(subject.get(page_id2).next_page).to eq(nil)

      expect(subject.get_pages_in_form(form_id).map(&:id)).to eq([page_id1, page_id2])

      subject.move_page_down(form_id, page_id1)

      expect(subject.get(page_id1).next_page).to eq(nil)
      expect(subject.get(page_id2).next_page).to eq(page_id1)

      pages = subject.get_pages_in_form(form_id)
      expect(pages.map(&:id)).to eq([page_id2, page_id1])
    end

    it "with two pages, moving the last does not change order" do
      page_id1 = subject.create(page)
      page_id2 = subject.create(page)

      expect(subject.get(page_id1).next_page).to eq(page_id2)
      expect(subject.get(page_id2).next_page).to eq(nil)

      subject.move_page_down(form_id, page_id2)

      expect(subject.get(page_id1).next_page).to eq(page_id2)
      expect(subject.get(page_id2).next_page).to eq(nil)

      expect(subject.get_pages_in_form(form_id).map(&:id)).to eq([page_id1, page_id2])
    end

    it "with two pages, moving the last does not change next_page" do
      page_id1 = subject.create(page)
      page_id2 = subject.create(page)

      expect(subject.get(page_id1).next_page).to eq(page_id2)
      expect(subject.get(page_id2).next_page).to eq(nil)

      subject.move_page_down(form_id, page_id2)

      expect(subject.get(page_id1).next_page).to eq(page_id2)
      expect(subject.get(page_id2).next_page).to eq(nil)

      expect(subject.get_pages_in_form(form_id).map(&:id)).to eq([page_id1, page_id2])
    end

    it "with three pages, moving the first does not change the last page" do
      page_id1 = subject.create(page)
      page_id2 = subject.create(page)
      page_id3 = subject.create(page)

      expect(subject.get(page_id1).next_page).to eq(page_id2)
      expect(subject.get(page_id2).next_page).to eq(page_id3)
      expect(subject.get(page_id3).next_page).to eq(nil)

      subject.move_page_down(form_id, page_id1)

      expect(subject.get(page_id1).next_page).to eq(page_id3)
      expect(subject.get(page_id2).next_page).to eq(page_id1)
      expect(subject.get(page_id3).next_page).to eq(nil)

      expect(subject.get_pages_in_form(form_id).map(&:id)).to eq([page_id2, page_id1, page_id3])
    end
  end

  describe "#move_page_up" do
    it "with a single page doesn't change the next_page id" do
      page_id1 = subject.create(page)

      subject.move_page_up(form_id, page_id1)
      first_page_next = subject.get(page_id1).next_page

      expect(first_page_next).to eq(nil)
      expect(subject.get_pages_in_form(form_id).map(&:id)).to eq([page_id1])
    end

    it "with two pages, moving the last changes the next_page id of both pages" do
      page_id1 = subject.create(page)
      page_id2 = subject.create(page)

      expect(subject.get(page_id1).next_page).to eq(page_id2)
      expect(subject.get(page_id2).next_page).to eq(nil)

      expect(subject.get_pages_in_form(form_id).map(&:id)).to eq([page_id1, page_id2])

      subject.move_page_up(form_id, page_id2)

      expect(subject.get(page_id1).next_page).to eq(nil)
      expect(subject.get(page_id2).next_page).to eq(page_id1)

      pages = subject.get_pages_in_form(form_id)
      expect(pages.map(&:id)).to eq([page_id2, page_id1])
    end

    it "with two pages, moving the first does not change order" do
      page_id1 = subject.create(page)
      page_id2 = subject.create(page)

      expect(subject.get(page_id1).next_page).to eq(page_id2)
      expect(subject.get(page_id2).next_page).to eq(nil)

      subject.move_page_up(form_id, page_id1)

      expect(subject.get(page_id1).next_page).to eq(page_id2)
      expect(subject.get(page_id2).next_page).to eq(nil)

      expect(subject.get_pages_in_form(form_id).map(&:id)).to eq([page_id1, page_id2])
    end

    it "with three pages, moving the last does not change the first page" do
      page_id1 = subject.create(page)
      page_id2 = subject.create(page)
      page_id3 = subject.create(page)

      expect(subject.get(page_id1).next_page).to eq(page_id2)
      expect(subject.get(page_id2).next_page).to eq(page_id3)
      expect(subject.get(page_id3).next_page).to eq(nil)

      subject.move_page_up(form_id, page_id3)

      expect(subject.get(page_id1).next_page).to eq(page_id3)
      expect(subject.get(page_id2).next_page).to eq(nil)
      expect(subject.get(page_id3).next_page).to eq(page_id2)

      expect(subject.get_pages_in_form(form_id).map(&:id)).to eq([page_id1, page_id3, page_id2])
    end
  end
end

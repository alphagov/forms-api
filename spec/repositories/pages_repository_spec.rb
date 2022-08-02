describe Repositories::PagesRepository do
  include_context "with database"

  let(:subject) { described_class.new(database) }
  let(:form_id) { database[:forms].insert(name: "name", submission_email: "email") }
  let(:page) do
    Domain::Page.new.tap do |page|
      page.form_id = form_id
      page.question_text = "question_text"
      page.question_short_name = "question_short_name"
      page.hint_text = "hint_text"
      page.answer_type = "answer_type"
      page.next = "next"
    end
  end

  context "creating a new page" do
    it "creates a page" do
      first_page_result = subject.create(page)
      subject.create(page)

      created_page = database[:pages].where(id: first_page_result).all.last

      expect(created_page[:question_text]).to eq("question_text")
      expect(created_page[:question_short_name]).to eq("question_short_name")
      expect(created_page[:hint_text]).to eq("hint_text")
      expect(created_page[:answer_type]).to eq("answer_type")
      expect(created_page[:form_id]).to eq(form_id)
    end
  end

  context "getting a page" do
    it "gets a page" do
      page_id = subject.create(page)
      found_page = subject.get(page_id)
      expect(found_page.question_text).to eq("question_text")
      expect(found_page.question_short_name).to eq("question_short_name")
      expect(found_page.hint_text).to eq("hint_text")
      expect(found_page.answer_type).to eq("answer_type")
      expect(found_page.form_id).to eq(form_id)
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
      page.next = "next_page"
      update_result = subject.update(page)

      page = subject.get(page_id)
      expect(update_result).to eq(1)
      expect(page.question_text).to eq("question_text2")
      expect(page.question_short_name).to eq("question_short_name2")
      expect(page.hint_text).to eq("hint_text2")
      expect(page.answer_type).to eq("answer_type2")
      expect(page.next).to eq("next_page")
      expect(page.form_id).to eq(form_id)
    end
  end

  context "deleting a page which exists" do
    it "deletes a page" do
      page_id = subject.create(page)
      result = subject.delete(page_id)

      expect(result).to eq(1)
    end

    it "updates other page next values" do
      first_page_id = subject.create(page)
      second_page_id = subject.create(page)
      third_page_id = subject.create(page)

      result = subject.delete(second_page_id)

      first_page_next = database[:pages].where(id: first_page_id).get(:next)
      expect(first_page_next).to eq(third_page_id.to_s)
      expect(result).to eq(1)
    end
  end

  context "deleting a page which does not exist" do
    it "does not update other page next values" do
      first_page_id = subject.create(page)
      second_page_id = subject.create(page)
      third_page_id = subject.create(page)

      result = subject.delete(999)

      first_page_next = database[:pages].where(id: first_page_id).get(:next)
      second_page_next = database[:pages].where(id: second_page_id).get(:next)
      third_page_next = database[:pages].where(id: third_page_id).get(:next)

      expect(result).to eq(0)
      expect(first_page_next).to eq(second_page_id.to_s)
      expect(second_page_next).to eq(third_page_id.to_s)
      expect(third_page_next).to eq(nil)
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
end

describe Repositories::PagesRepository do
  include_context "with database"

  let(:subject) { described_class.new(database) }
  let(:form_id) do
    repository = Repositories::FormsRepository.new(@database)
    repository.create("name", "email", "org")
  end
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
      result = subject.create(page)
      created_page = database[:pages].where(id: result).all.last

      expect(created_page[:question_text]).to eq("question_text")
      expect(created_page[:question_short_name]).to eq("question_short_name")
      expect(created_page[:hint_text]).to eq("hint_text")
      expect(created_page[:answer_type]).to eq("answer_type")
      expect(created_page[:next]).to eq("next")
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
      expect(found_page.next).to eq("next")
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

      repository = Repositories::FormsRepository.new(@database)
      form = repository.get(form_id)
      puts form
      expect(form[:created_at].to_i).to be_within(0).of(Time.now.to_i)
      expect(form[:updated_at].to_i).to be_within(0).of(Time.now.to_i)
    end
  end

  context "deleting a page" do
    it "deletes a page" do
      page_id = subject.create(page)
      result = subject.delete(page_id)
      expect(result).to eq(1)
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

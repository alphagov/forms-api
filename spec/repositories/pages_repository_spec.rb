describe Repositories::PagesRepository do
  include_context "with database"

  let(:subject) { described_class.new(database) }
  let(:form_id) { database[:forms].insert(name: "name", submission_email: "email") }

  context "creating a new page" do
    it "creates a page" do
      result = subject.create(form_id, "question_text", "question_short_name", "hint_text", "answer_type")
      created_page = database[:pages].where(id: result).all.last
      expect(created_page[:question_text]).to eq("question_text")
      expect(created_page[:question_short_name]).to eq("question_short_name")
      expect(created_page[:hint_text]).to eq("hint_text")
      expect(created_page[:answer_type]).to eq("answer_type")
      expect(created_page[:form_id]).to eq(form_id)
    end
  end

  context "getting a page" do
    it "gets a page" do
      page_id = subject.create(form_id, "question_text", "question_short_name", "hint_text", "answer_type")
      page = subject.get(page_id)
      expect(page[:question_text]).to eq("question_text")
      expect(page[:question_short_name]).to eq("question_short_name")
      expect(page[:hint_text]).to eq("hint_text")
      expect(page[:answer_type]).to eq("answer_type")
      expect(page[:form_id]).to eq(form_id)
    end
  end

  context "updating a page" do
    it "updates a page" do
      page_id = subject.create(form_id, "question_text", "question_short_name", "hint_text", "answer_type")
      update_result = subject.update(page_id, "question_text2", "question_short_name2", "hint_text2", "answer_type2")
      page = subject.get(page_id)
      expect(update_result).to eq(1)
      expect(page[:question_text]).to eq("question_text2")
      expect(page[:question_short_name]).to eq("question_short_name2")
      expect(page[:hint_text]).to eq("hint_text2")
      expect(page[:answer_type]).to eq("answer_type2")
      expect(page[:form_id]).to eq(form_id)
    end
  end

  context "deleting a page" do
    it "deletes a page" do
      page_id = subject.create(form_id, "question_text", "question_short_name", "hint_text", "answer_type")
      result = subject.delete(page_id)
      expect(result).to eq(1)
    end
  end

  context "getting pages for a form" do
    it "gets pages for a form" do
      page_id1 = subject.create(form_id, "question_text", "question_short_name", "hint_text", "answer_type")
      page_id2 = subject.create(form_id, "question_text", "question_short_name", "hint_text", "answer_type")
      pages = subject.get_pages_in_form(form_id)
      expect(pages.length).to eq(2)
      expect(pages[0][:id]).to eq(page_id1)
      expect(pages[1][:id]).to eq(page_id2)
    end
  end
end

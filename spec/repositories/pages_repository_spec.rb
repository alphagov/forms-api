describe Repositories::PagesRepository do
  include_context "with database"

  context "creating a new page" do
    it "creates a page" do
      subject = described_class.new(database)
      form_id = database[:forms].insert(name: "name", submission_email: "email")
      result = subject.create(form_id, "question_text", "question_short_name", "hint_text", "answer_type")
      created_page = database[:pages].where(id: result).all.last
      expect(created_page[:question_text]).to eq("question_text")
      expect(created_page[:question_short_name]).to eq("question_short_name")
      expect(created_page[:hint_text]).to eq("hint_text")
      expect(created_page[:answer_type]).to eq("answer_type")
      expect(created_page[:form_id]).to eq(form_id)
    end
  end
end

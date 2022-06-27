describe Domain::Page do  

    it "creates the correct hash for the page" do
      test_page = Domain::Page.new.tap do |page|
        page.id = "1234"
        page.form_id = "5678"
        page.question_text = "question_text"
        page.question_short_name = "question_short_name"
        page.hint_text = "hint_text"
        page.answer_type = "answer_type"
        page.next = "next"
      end
      hashed_page = test_page.to_h
      expect(hashed_page[:question_text]).to eq("question_text")
      expect(hashed_page[:question_short_name]).to eq("question_short_name")
      expect(hashed_page[:hint_text]).to eq("hint_text")
      expect(hashed_page[:answer_type]).to eq("answer_type")
      expect(hashed_page[:next]).to eq("next")
      expect(hashed_page[:form_id]).to eq("5678")
      expect(hashed_page[:id]).to eq("1234")
    end
end
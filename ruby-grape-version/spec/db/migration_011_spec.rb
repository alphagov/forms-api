describe "migration 11" do
  include_context "with database"

  let(:migrator) { Migrator.new }

  before do
    migrator.migrate_to(database, 10)
  end
  it "changes type of _next_page from string to int from v10 to v11" do
    form1 = database[:forms].insert(name: "name", submission_email: "submission_email", org: "testorg")
    form2 = database[:forms].insert(name: "name", submission_email: "submission_email", org: "testorg")

    page_id1 = database[:pages].insert(id: 1, form_id: form1, next_page: "2", question_text: "question_text", answer_type: "answer_type")
    page_id2 = database[:pages].insert(id: 2, form_id: form1, next_page: "3", question_text: "question_text", answer_type: "answer_type")
    page_id3 = database[:pages].insert(id: 3, form_id: form2, next_page: nil, question_text: "question_text", answer_type: "answer_type")

    migrator.migrate_to(database, 11)

    expect(database[:pages].where(id: page_id1).first[:next_page]).to eq(page_id2)

    expect(database[:pages].where(id: page_id2).first[:next_page]).to eq(page_id3)
    expect(database[:pages].where(id: page_id3).first[:next_page]).to be_nil
  end
end

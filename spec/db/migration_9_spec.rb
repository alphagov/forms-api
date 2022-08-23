describe "migration 9" do
  include_context "with database"

  let(:migrator) { Migrator.new }

  before do
    migrator.migrate_to(database, 8)
  end
  it "adds renames next to next_page and changes type to int from v8 to v9" do
    form1 = database[:forms].insert(name: "name", submission_email: "submission_email", org: "testorg")
    form2 = database[:forms].insert(name: "name", submission_email: "submission_email", org: "testorg")

    page_id1 = database[:pages].insert(id: 1, form_id: form1, next: "2", question_text: "question_text", answer_type: "answer_type")
    page_id2 = database[:pages].insert(id: 2, form_id: form1, next: "3", question_text: "question_text", answer_type: "answer_type")
    page_id3 = database[:pages].insert(id: 3, form_id: form2, next: nil, question_text: "question_text", answer_type: "answer_type")

    migrator.migrate_to(database, 9)

    expect(database[:pages].where(id: page_id1).first[:next]).to be_nil
    expect(database[:pages].where(id: page_id1).first[:next_page]).to eq(page_id2.to_s)

    expect(database[:pages].where(id: page_id2).first[:next_page]).to eq(page_id3.to_s)
    expect(database[:pages].where(id: page_id3).first[:next_page]).to be_nil
  end
end

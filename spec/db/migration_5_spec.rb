describe "migration 5" do
  include_context "with database"

  let(:migrator) { Migrator.new }

  before do
    migrator.migrate_to(database, 4)
  end
  it "adds a sensible default org from v4 to v5" do
    form1 = database[:forms].insert(name: "Form 1", submission_email: "submission_email")
    form2 = database[:forms].insert(name: "Form 2", submission_email: "submission_email")

    page_id1 = database[:pages].insert(id: 1, form_id: form1, next: "2", question_text: "question_text", answer_type: "answer_type")
    page_id2 = database[:pages].insert(id: 2, form_id: form1, next: "3", question_text: "question_text", answer_type: "answer_type")
    page_id3 = database[:pages].insert(id: 3, form_id: form2, next: nil, question_text: "question_text", answer_type: "answer_type")

    migrator.migrate_to(database, 5)

    expect(database[:pages].where(id: page_id1).first[:next]).to eq(page_id2.to_s)
    expect(database[:pages].where(id: page_id2).first[:next]).to be_nil
    expect(database[:pages].where(id: page_id3).first[:next]).to be_nil
  end
end

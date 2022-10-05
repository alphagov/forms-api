describe "migration 14" do
  include_context "with database"

  let(:migrator) { Migrator.new }

  before do
    migrator.migrate_to(database, 12)
  end
  it "adds `is_optional` to pages from v13 to v14" do
    form = database[:forms].insert(name: "Form", submission_email: "submission_email")
    page1_id = database[:pages].insert(id: 1, form_id: form, next_page: "2", question_text: "question_text", answer_type: "answer_type")
    page2_id = database[:pages].insert(id: 2, form_id: form, next_page: "3", question_text: "question_text", answer_type: "answer_type")

    migrator.migrate_to(database, 14)

    database[:pages].where(id: page1_id).update(is_optional: true)

    page1 = database[:pages].where(id: page1_id).first
    page2 = database[:pages].where(id: page2_id).first

    expect(page1[:is_optional]).to be true
    expect(page2[:is_optional]).to be_nil
  end
end

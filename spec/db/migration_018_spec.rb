describe "migration 18" do
  include_context "with database"

  let(:migrator) { Migrator.new }

  before do
    migrator.migrate_to(database, 17)
  end
  it "adds an answer_settings field to pages table from v17 to v18" do
    form = database[:forms].insert(name: "Form", submission_email: "submission_email")
    page1_id = database[:pages].insert(id: 1, form_id: form, next_page: "2", question_text: "question_text", answer_type: "answer_type")
    page2_id = database[:pages].insert(id: 2, form_id: form, next_page: "3", question_text: "question_text", answer_type: "answer_type")

    migrator.migrate_to(database, 18)

    answer_settings = { only_one_option: true }.to_json
    database[:pages].where(id: page1_id).update(answer_settings:)

    page1 = database[:pages].where(id: page1_id).first

    page2 = database[:pages].where(id: page2_id).first

    expect(page1[:answer_settings].to_json).to eq(answer_settings)
    expect(page2[:answer_settings]).to be_nil
  end
end

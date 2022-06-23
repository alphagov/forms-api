require "pry"

describe "migration 3" do
  include_context "with database"

  let(:migrator) { Migrator.new }

  before do
    migrator.migrate_to(database, 2)
  end
  it "migrates to the correct version" do
    form_id = database[:forms].insert(name: "name", submission_email: "submission_email")

    page_id1 = database[:pages].insert(form_id:, question_text: "question_text", question_short_name: "question_short_name", hint_text: "hint_text", answer_type: "answer_type")
    page_id2 = database[:pages].insert(form_id:, question_text: "question_text", question_short_name: "question_short_name", hint_text: "hint_text", answer_type: "answer_type")
    page_id3 = database[:pages].insert(form_id:, question_text: "question_text", question_short_name: "question_short_name", hint_text: "hint_text", answer_type: "answer_type")

    migrator.migrate_to(database, 3)

    expect(database[:pages].where(id: page_id1).first[:next]).to eq(page_id2.to_s)
    expect(database[:pages].where(id: page_id2).first[:next]).to eq(page_id3.to_s)
    expect(database[:pages].where(id: page_id3).first[:next]).to be_nil
  end
end

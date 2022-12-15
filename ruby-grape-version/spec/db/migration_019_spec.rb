describe "migration 19" do
  include_context "with database"

  let(:migrator) { Migrator.new }

  before do
    migrator.migrate_to(database, 18)
  end

  it "adds correct page page_order values to forms" do
    empty_form = database[:forms].insert(name: "name 1", submission_email: "submission_email", org: "testorg")

    single_page_form = database[:forms].insert(name: "name 2", submission_email: "submission_email", org: "testorg")
    page_id1 = database[:pages].insert(form_id: single_page_form, question_text: "question_text", question_short_name: "question_short_name", hint_text: "hint_text", answer_type: "answer_type")

    multi_page_form = database[:forms].insert(name: "name 3", submission_email: "submission_email", org: "testorg")
    page_id2 = database[:pages].insert(form_id: multi_page_form, question_text: "question_text", question_short_name: "question_short_name", hint_text: "hint_text", answer_type: "answer_type")
    page_id3 = database[:pages].insert(form_id: multi_page_form, question_text: "question_text", question_short_name: "question_short_name", hint_text: "hint_text", answer_type: "answer_type")
    page_id4 = database[:pages].insert(form_id: multi_page_form, question_text: "question_text", question_short_name: "question_short_name", hint_text: "hint_text", answer_type: "answer_type")

    other_multi_page_form = database[:forms].insert(name: "name 3", submission_email: "submission_email", org: "testorg")
    page_id5 = database[:pages].insert(form_id: other_multi_page_form, question_text: "question_text", question_short_name: "question_short_name", hint_text: "hint_text", answer_type: "answer_type")
    page_id6 = database[:pages].insert(form_id: other_multi_page_form, question_text: "question_text", question_short_name: "question_short_name", hint_text: "hint_text", answer_type: "answer_type")
    page_id7 = database[:pages].insert(form_id: other_multi_page_form, question_text: "question_text", question_short_name: "question_short_name", hint_text: "hint_text", answer_type: "answer_type")

    migrator.migrate_to(database, 19)

    expect(database[:forms].where(id: empty_form).get(:page_order)).to eq([])
    expect(database[:forms].where(id: single_page_form).get(:page_order)).to eq([page_id1])
    expect(database[:forms].where(id: multi_page_form).get(:page_order)).to eq([page_id2, page_id3, page_id4])
    expect(database[:forms].where(id: other_multi_page_form).get(:page_order)).to eq([page_id5, page_id6, page_id7])
  end
end

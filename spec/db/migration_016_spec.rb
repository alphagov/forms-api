describe "migration 16" do
  include_context "with database"

  let(:migrator) { Migrator.new }

  before do
    migrator.migrate_to(database, 15)
  end
  it "adds a question_section_completed field to forms table from v15 to v16" do
    question_not_completed_form_id = database[:forms].insert(name: "name 1", submission_email: "submission_email", org: "testorg")
    question_section_completed_form_id = database[:forms].insert(name: "name 2", submission_email: "submission_email", org: "testorg")

    migrator.migrate_to(database, 16)

    database[:forms].where(id: question_section_completed_form_id).update(question_section_completed: true)

    updated_form = database[:forms].where(id: question_section_completed_form_id).first

    expect(updated_form[:question_section_completed]).to eq true

    existing_form = database[:forms].where(id: question_not_completed_form_id).first

    expect(existing_form[:question_section_completed]).to eq false

  end
end

describe "migration 12" do
  include_context "with database"

  let(:migrator) { Migrator.new }

  before do
    migrator.migrate_to(database, 11)
  end
  it "adds a what_happens_next_text field to forms table from v11 to v12" do
    form_id = database[:forms].insert(name: "name", submission_email: "submission_email", org: "testorg")

    migrator.migrate_to(database, 12)

    database[:forms].where(id: form_id).update(what_happens_next_text: "some text on what happens next")

    updated_form = database[:forms].where(id: form_id).first

    expect(updated_form[:what_happens_next_text]).to eq("some text on what happens next 1")
  end
end

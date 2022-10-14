describe "migration 14" do
  include_context "with database"

  let(:migrator) { Migrator.new }

  before do
    migrator.migrate_to(database, 14)
  end
  it "adds a declaration_text field to forms table from v14 to v15" do
    form_id = database[:forms].insert(name: "name", submission_email: "submission_email", org: "testorg")

    migrator.migrate_to(database, 15)

    database[:forms].where(id: form_id).update(declaration_text: "some declaration text")

    updated_form = database[:forms].where(id: form_id).first

    expect(updated_form[:declaration_text]).to eq("some declaration text")
  end
end

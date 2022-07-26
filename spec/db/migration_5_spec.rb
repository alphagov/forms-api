describe "migration 5" do
  include_context "with database"

  let(:migrator) { Migrator.new }

  before do
    migrator.migrate_to(database, 4)
  end
  it "adds a sensible default published from v4 to v5" do
    form_id = database[:forms].insert(name: "name", submission_email: "submission_email", org: "testorg")

    migrator.migrate_to(database, 5)

    updated_form = database[:forms].where(id: form_id).first
    expect(updated_form[:published]).to eq(false)
  end
end

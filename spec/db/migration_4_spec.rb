describe "migration 4" do
  include_context "with database"

  let(:migrator) { Migrator.new }

  before do
    migrator.migrate_to(database, 3)
  end
  it "adds a sensible default org from v3 to v4" do
    form_id = database[:forms].insert(name: "name", submission_email: "submission_email")

    migrator.migrate_to(database, 4)

    updated_form = database[:forms].where(id: form_id).first
    expect(updated_form[:org]).to eq("government-digital-service")
  end
end

describe "migration 6" do
  include_context "with database"

  let(:migrator) { Migrator.new }

  before do
    migrator.migrate_to(database, 5)
  end
  it "adds a sensible default published from v5 to v6" do
    form_id = database[:forms].insert(name: "name", submission_email: "submission_email", org: "testorg")

    migrator.migrate_to(database, 6)

    updated_form = database[:forms].where(id: form_id).first
    expect(updated_form[:published_at]).to eq(nil)
    expect(updated_form[:created_at]).to eq(nil)
    expect(updated_form[:update_at]).to eq(nil)
  end
end

describe "migration 8" do
  include_context "with database"

  let(:migrator) { Migrator.new }

  before do
    migrator.migrate_to(database, 7)
  end
  it "adds a sensible default org from v7 to v8" do
    form_id = database[:forms].insert(name: "name", submission_email: "submission_email")

    migrator.migrate_to(database, 8)

    database[:forms].where(id: form_id).update(privacy_policy_url: "https://www.example.com")

    updated_form = database[:forms].where(id: form_id).first

    expect(updated_form[:privacy_policy_url]).to eq("https://www.example.com")
  end
end

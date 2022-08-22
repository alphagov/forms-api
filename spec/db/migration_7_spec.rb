describe "migration 7" do
  include_context "with database"

  let(:migrator) { Migrator.new }

  before do
    migrator.migrate_to(database, 6)
  end
  it "Update old forms with a created and updated date" do
    form_id = database[:forms].insert(name: "name", submission_email: "submission_email", org: "testorg")
    migrator.migrate_to(database, 7)

    expect(@database[:forms].where(created_at: nil).first).to be_nil

    expect(@database[:forms].where(id: form_id).first[:created_at]).to be_within(1).of(Time.now)
  end
end

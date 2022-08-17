describe "migration 7" do
  include_context "with database"

  let(:migrator) { Migrator.new }

  before do
    migrator.migrate_to(database, 6)
  end
  it "Update old forms with a created and updated date" do
    no_created_form = database[:forms].insert(name: "Form 2", submission_email: "submission_email")
    uncreated_forms = database[:forms].where(created_at: nil)

    @database[:forms].where(created_at: nil).update(
      updated_at: Time.now,
      created_at: Time.now,
    )

    expect(@database[:forms].where(created_at: nil).first).to be_nil
  end
end

describe "migration 17" do
  include_context "with database"

  let(:migrator) { Migrator.new }

  before do
    migrator.migrate_to(database, 16)
  end
  it "adds a declaration_section_completed field to forms table from v16 to v17" do
    declaration_not_completed_form_id = database[:forms].insert(name: "name 1", submission_email: "submission_email", org: "testorg")
    declaration_section_completed_form_id = database[:forms].insert(name: "name 2", submission_email: "submission_email", org: "testorg")

    migrator.migrate_to(database, 17)

    database[:forms].where(id: declaration_section_completed_form_id).update(declaration_section_completed: true)

    updated_form = database[:forms].where(id: declaration_section_completed_form_id).first

    expect(updated_form[:declaration_section_completed]).to eq true

    existing_form = database[:forms].where(id: declaration_not_completed_form_id).first

    expect(existing_form[:declaration_section_completed]).to eq false
  end

  it "marks existing live forms declaration_section_completed to true" do
    live_form_id = database[:forms].insert(name: "name 1", submission_email: "submission_email", org: "testorg", live_at: Time.now)
    draft_form_id = database[:forms].insert(name: "name 2", submission_email: "submission_email", org: "testorg")

    migrator.migrate_to(database, 17)

    live_form = database[:forms].where(id: live_form_id).first

    expect(live_form[:declaration_section_completed]).to eq true

    draft_form = database[:forms].where(id: draft_form_id).first

    expect(draft_form[:declaration_section_completed]).to eq false
  end
end

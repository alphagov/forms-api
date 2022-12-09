describe "migration 13" do
  include_context "with database"

  let(:migrator) { Migrator.new }
  let(:support_email) { "test@email.com" }
  let(:support_phone) { "8675309" }
  let(:support_url) { "http://www.example.com" }
  let(:support_url_text) { "Support page" }

  before do
    migrator.migrate_to(database, 12)
  end
  it "adds contact details to forms from v12 to v13" do
    form_id = database[:forms].insert(name: "name", submission_email: "submission_email", org: "testorg")

    migrator.migrate_to(database, 13)

    database[:forms].where(id: form_id).update(support_email:, support_phone:, support_url:, support_url_text:)

    updated_form = database[:forms].where(id: form_id).first

    expect(updated_form[:support_email]).to eq(support_email)
    expect(updated_form[:support_phone]).to eq(support_phone)
    expect(updated_form[:support_url]).to eq(support_url)
    expect(updated_form[:support_url_text]).to eq(support_url_text)
  end
end

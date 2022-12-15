describe "migration 10" do
  include_context "with database"

  let(:migrator) { Migrator.new }

  describe "migrating to next version" do
    before do
      migrator.migrate_to(database, 9)
    end
    it "adds form_slug column to form table" do
      form1 = database[:forms].insert(name: "Form 1 Name", submission_email: "submission_email", org: "testorg")

      migrator.migrate_to(database, 10)

      form2 = database[:forms].insert(name: "Form 2 Name", submission_email: "submission_email", org: "testorg", form_slug: "form-2-name")

      expect(database[:forms].where(id: form1).first[:form_slug]).to eq "form-1-name"
      expect(database[:forms].where(id: form2).first[:form_slug]).to eq "form-2-name"
    end
  end
end

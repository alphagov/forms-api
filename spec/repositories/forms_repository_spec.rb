describe Repositories::FormsRepository do
  include_context "with database"

  let(:subject) { described_class.new(database) }

  context "creating a new form" do
    it "creates a form" do
      result = subject.create("name", "submission_email", "org")
      created_form = database[:forms].where(id: result).all.last
      expect(created_form[:name]).to eq("name")
      expect(created_form[:submission_email]).to eq("submission_email")
      expect(created_form[:org]).to eq("org"
    end
  end

  context "getting a form" do
    it "gets a form" do
      form_id = subject.create("name", "submission_email", "org")
      form = subject.get(form_id)
      expect(form[:name]).to eq("name")
      expect(form[:submission_email]).to eq("submission_email")
      expect(form[:org]).to eq("org")
    end
  end

  context "updating a form" do
    it "updates a form" do
      form_id = subject.create("name", "submission_email", "org")
      update_result = subject.update(form_id, "name2", "submission_email2", "org2")
      form = subject.get(form_id)
      expect(update_result).to eq(1)
      expect(form[:name]).to eq("name2")
      expect(form[:submission_email]).to eq("submission_email2")
      expect(form[:org]).to eq("org2")
    end
  end

  context "deleting a form" do
    it "deletes a form" do
      form_id = subject.create("name", "submission_email", "org")
      result = subject.delete(form_id)
      expect(result).to eq(1)
    end
  end

  context "getting all forms" do
    it "gets all forms" do
      form_id1 = subject.create("name", "submission_email", "org")
      form_id2 = subject.create("name", "submission_email", "org")
      forms = subject.fetch_all
      expect(forms.length).to eq(2)
      expect(forms[0][:id]).to eq(form_id1)
      expect(forms[1][:id]).to eq(form_id2)
    end
  end
end

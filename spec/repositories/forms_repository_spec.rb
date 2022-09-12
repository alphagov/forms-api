require "date"

describe Repositories::FormsRepository do
  include_context "with database"

  let(:subject) { described_class.new(database) }

  context "creating a new form" do
    it "creates a form" do
      result = subject.create("Form 1 (basic form)?", "submission_email", "org")
      created_form = database[:forms].where(id: result).all.last
      expect(created_form[:name]).to eq("Form 1 (basic form)?")
      expect(created_form[:submission_email]).to eq("submission_email")
      expect(created_form[:org]).to eq("org")
      expect(created_form[:form_slug]).to eq("form-1-basic-form")
      expect(created_form[:live_at]).to eq(nil)
      expect(created_form[:created_at].to_i).to be_within(3).of(Time.now.to_i)
      expect(created_form[:updated_at].to_i).to be_within(3).of(Time.now.to_i)
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
    it "gets a form by org" do
      subject.create("name", "submission_email", "org")
      subject.create("name2", "submission_email", "org")
      forms = subject.get_by_org("org")
      expect(forms.length).to eq(2)
      expect(forms[0][:name]).to eq("name")
      expect(forms[0][:submission_email]).to eq("submission_email")
      expect(forms[0][:org]).to eq("org")
      expect(forms[1][:name]).to eq("name2")
      expect(forms[1][:submission_email]).to eq("submission_email")
      expect(forms[1][:org]).to eq("org")
    end
  end

  context "updating a form" do
    it "updates a form" do
      form_id = subject.create("Form 1 (basic form)?", "submission_email", "org")
      update_result = subject.update({ form_id:, name: "Form 2 (basic form)?", submission_email: "submission_email2", org: "org2", live_at: Time.now, privacy_policy_url: "https://example.com/privacy-policy", what_happens_next_text: "text on what happens next" })
      form = subject.get(form_id)
      expect(update_result).to eq(1)
      expect(form[:name]).to eq("Form 2 (basic form)?")
      expect(form[:submission_email]).to eq("submission_email2")
      expect(form[:org]).to eq("org2")
      expect(form[:form_slug]).to eq("form-2-basic-form")
      expect(form[:updated_at].to_i).to be_within(3).of(Time.now.to_i)
      expect(form[:live_at].to_i).to be_within(3).of(Time.now.to_i)
      expect(form[:privacy_policy_url]).to eq("https://example.com/privacy-policy")
      expect(form[:what_happens_next_text]).to eq("text on what happens next")
    end
  end

  context "deleting a form" do
    it "deletes a form" do
      form_id = subject.create("name", "submission_email", "org")
      result = subject.delete(form_id)
      expect(result).to eq(1)
    end

    it "deletes associated pages for the form" do
      form_id = subject.create("name", "submission_email", "org")
      database[:pages].insert(form_id:, question_text: "question_text", answer_type: "email")
      subject.delete(form_id)
      pages = database[:pages].where(form_id:)
      expect(pages.count).to eq(0)
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

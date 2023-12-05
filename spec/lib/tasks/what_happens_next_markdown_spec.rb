require "rails_helper"
require "rake"

RSpec.describe "what_happens_next_markdown.rake" do
  describe "what_happens_next_markdown:populate", type: :task do
    before do
      Rake.application.rake_require "tasks/what_happens_next_markdown"
      Rake::Task.define_task(:environment)
    end

    it "populates the what_happens_next_markdown field on the form and the live form JSON" do
      form = create(:form, what_happens_next_text: "You will get a response soon.\n\nIn the meantime:<ul><li>A list item</li></ul>", what_happens_next_markdown: nil)
      made_live_form = create(:made_live_form, form:)

      Rake::Task["what_happens_next_markdown:populate"].invoke

      form.reload
      made_live_form.reload

      made_live_form_blob = JSON.parse(made_live_form.json_form_blob, symbolize_names: true)
      expect(form.what_happens_next_markdown).to eq "You will get a response soon.\n\nIn the meantime:\n\n- A list item"
      expect(made_live_form_blob[:what_happens_next_markdown]).to eq "You will get a response soon.\n\nIn the meantime:\n\n- A list item"
    end
  end

  describe "what_happens_next_markdown:depopulate", type: :task do
    before do
      Rake.application.rake_require "tasks/what_happens_next_markdown"
      Rake::Task.define_task(:environment)
    end

    it "removes the what_happens_next_markdown content from the form and the live form JSON" do
      form = create(:form, what_happens_next_text: "You will get a response soon.\n\nIn the meantime:<ul><li>A list item</li></ul>", what_happens_next_markdown: "You will get a response soon.\n\nIn the meantime:\n\n- A list item")
      made_live_form = create(:made_live_form, form:)

      Rake::Task["what_happens_next_markdown:depopulate"].invoke

      form.reload
      made_live_form.reload

      made_live_form_blob = JSON.parse(made_live_form.json_form_blob, symbolize_names: true)
      expect(form.what_happens_next_markdown).to eq nil
      expect(made_live_form_blob[:what_happens_next_markdown]).to eq nil
    end
  end
end

class CreateForms < ActiveRecord::Migration[7.0]
  def change
    create_table :forms do |t|
      t.text :name
      t.text :submission_email
      t.text :org
      t.datetime :live_at
      t.text :privacy_policy_url
      t.text :form_slug
      t.text :what_happens_next_text
      t.text :support_email
      t.text :support_phone
      t.text :support_url
      t.text :support_url_text
      t.text :declaration_text
      t.boolean :question_section_completed, default: false
      t.boolean :declaration_section_completed, default: false
      t.integer :page_order, array: true

      t.timestamps
    end
  end
end

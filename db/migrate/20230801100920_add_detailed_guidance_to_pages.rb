class AddDetailedGuidanceToPages < ActiveRecord::Migration[7.0]
  def change
    change_table :pages, bulk: true do |t|
      t.text :page_heading
      t.text :detailed_guidance_markdown
    end
  end
end

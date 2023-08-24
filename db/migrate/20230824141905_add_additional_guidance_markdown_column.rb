class AddAdditionalGuidanceMarkdownColumn < ActiveRecord::Migration[7.0]
  def change
    add_column :pages, :additional_guidance_markdown, :text
  end
end

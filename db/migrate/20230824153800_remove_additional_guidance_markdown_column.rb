class RemoveAdditionalGuidanceMarkdownColumn < ActiveRecord::Migration[7.0]
  def change
    remove_column :pages, :additional_guidance_markdown, :text
  end
end

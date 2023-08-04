class RenamePagesDetailedGuidanceMarkdownToAdditionalGuidanceMarkdown < ActiveRecord::Migration[7.0]
  def change
    rename_column :pages, :detailed_guidance_markdown, :additional_guidance_markdown
  end
end

class ChangeAdditionalGuidanceMarkdownToGuidanceMarkdown < ActiveRecord::Migration[7.0]
  def change
    rename_column :pages, :additional_guidance_markdown, :guidance_markdown
  end
end

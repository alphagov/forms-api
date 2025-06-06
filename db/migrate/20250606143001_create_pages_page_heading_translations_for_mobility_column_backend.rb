class CreatePagesPageHeadingTranslationsForMobilityColumnBackend < ActiveRecord::Migration[8.0]
  def change
    add_column :pages, :page_heading_en, :text
    add_column :pages, :page_heading_cy, :text
  end
end

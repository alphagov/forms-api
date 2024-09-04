# Currently this is just a facade around the v1 Form model,
# as it uses the same database table
class Api::V2::Form < ApplicationRecord
  include Rails.application.routes.url_helpers # TODO: do we need a presenter instead?

  self.table_name = "forms"

  def as_json(_options = nil)
    {
      id: external_id,
      links: {
        self: api_v2_form_path(self),
        **document_links,
      },
    }
  end

  def to_param
    external_id
  end

private

  def document_tags
    Api::V2::FormDocumentRepository.tags_for_form(id)
  end

  def document_links
    document_tags.index_with do |tag|
      api_v2_form_document_path(self, tag:)
    end
  end
end

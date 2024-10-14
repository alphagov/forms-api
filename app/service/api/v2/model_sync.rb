class Api::V2::ModelSync
  def initialize
    @converter = Api::V2::Converter.new
  end

  def create_form(id, external_id, form_blob)
    update_or_create_form_document(id, :draft, form_blob, form_id: external_id)
  end

  def update_draft(id, form_blob, external_id)
    update_or_create_form_document(id, :draft, form_blob, form_id: external_id)
  end

  def make_live(id, form_blob, from_state, external_id)
    update_or_create_form_document(id, :live, form_blob, form_id: external_id)
    cleanup_form_documents(id, from_state)
  end

  def archive_live_form(id, form_blob, external_id)
    update_or_create_form_document(id, :archived, form_blob, form_id: external_id)
    delete_form_documents(id, :live)
  end

private

  def update_or_create_form_document(id, tag, form_blob, options = {})
    form_document = Api::V2::FormDocument.find_or_initialize_by(form_id: id, tag:)
    form_document.content = @converter.to_api_v2_form_document(form_blob, **options)
    form_document.save!
  end

  def cleanup_form_documents(id, from_state)
    delete_form_documents(id, :draft) if %i[draft archived_with_draft live_with_draft].include?(from_state)
    delete_form_documents(id, :archived) if %i[archived archived_with_draft].include?(from_state)
  end

  def delete_form_documents(id, tag)
    Api::V2::FormDocument.where(form_id: id, tag:).delete_all
  end
end

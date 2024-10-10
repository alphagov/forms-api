class Api::V2::FormDocumentSyncService
  def synchronize_form(form)
    case form.state
    when "live"
      sync_live_form(form)
    when "live_with_draft"
      sync_live_with_draft_form(form)
    when "draft"
      sync_draft_form(form)
    when "archived"
      sync_archived_form(form)
    when "archived_with_draft"
      sync_archived_with_draft_form(form)
    end
  end

  def sync_live_form(form)
    update_or_create_form_document(form, :live, JSON.parse(form.live_version))
    delete_form_documents(form, %i[draft archived])
  end

  def sync_live_with_draft_form(form)
    update_or_create_form_document(form, :live, JSON.parse(form.live_version))
    update_or_create_form_document(form, :draft, form.snapshot)
    delete_form_documents(form, [:archived])
  end

  def sync_draft_form(form)
    update_or_create_form_document(form, :draft, form.snapshot)
    delete_form_documents(form, %i[live archived])
  end

  def sync_archived_form(form)
    update_or_create_form_document(form, :archived, form.snapshot)
    delete_form_documents(form, %i[live draft])
  end

  def sync_archived_with_draft_form(form)
    update_or_create_form_document(form, :archived, form.snapshot)
    update_or_create_form_document(form, :draft, form.snapshot)
    delete_form_documents(form, [:live])
  end

  def update_or_create_form_document(form, tag, form_blob)
    form_document = Api::V2::FormDocument.find_or_initialize_by(form_id: form.id, tag:)
    form_document.content = Api::V2::Converter.new.to_api_v2_form_document(form_blob, form_id: form.external_id)
    form_document.save!
  end

  def delete_form_documents(form, tags)
    Api::V2::FormDocument.where(form_id: form.id, tag: tags).delete_all
  end
end

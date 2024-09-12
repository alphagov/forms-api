class Api::V2::FormDocumentRepository
  class << self
    def find(form_id, tag)
      v1_form = Form.find(form_id)
      v1_blob = v1_blob(v1_form, tag)
      raise ActiveRecord::RecordNotFound, "Could not find #{tag} form document for #{v1_form.inspect}" if v1_blob.blank?

      form_snapshot = JSON.parse!(v1_blob)
      converter.to_api_v2_form_document(form_snapshot, form_id: v1_form.external_id)
    end

    def tags_for_form(form_id)
      v1_form = Form.find(form_id)
      v1_tags(v1_form)
    end

  private

    def converter
      @converter ||= Api::V2::Converter.new
    end

    def v1_tags(v1_form)
      tags = []
      tags << :draft if v1_form.has_draft_version
      tags << :live if v1_form.has_live_version
      tags << :archived if v1_form.has_been_archived
      tags
    end

    def v1_blob(v1_form, tag)
      case tag.to_sym
      when :draft
        v1_form.draft_version if v1_form.has_draft_version
      when :live
        v1_form.live_version if v1_form.has_live_version
      when :archived
        v1_form.archived_live_version if v1_form.has_been_archived
      end
    end
  end
end

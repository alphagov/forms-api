module FormStateMachine
  extend ActiveSupport::Concern

  included do
    include AASM

    enum :state, {
      draft: "draft",
      deleted: "deleted",
      live: "live",
      live_with_draft: "live_with_draft",
      archived: "archived",
      archived_with_draft: "archived_with_draft",
    }

    aasm column: :state, enum: true do
      state :draft, initial: true
      state :deleted, :live, :live_with_draft, :archived, :archived_with_draft

      event :delete_form do
        after do
          destroy!
        end

        transitions from: :draft, to: :deleted
      end

      event :make_live do
        after do
          live_at ||= Time.zone.now
          touch(time: live_at)

          form_blob = snapshot(live_at:)
          made_live_forms.create!(json_form_blob: form_blob.to_json, created_at: live_at)

          Api::V2::FormDocumentSyncService.new.synchronize_form(self)
        end

        transitions from: %i[draft live_with_draft archived archived_with_draft], to: :live, guard: proc { ready_for_live }
      end

      event :create_draft_from_live_form do
        after do
          update!(share_preview_completed: false)
        end

        transitions from: :live, to: :live_with_draft
      end

      event :create_draft_from_archived_form do
        after do
          update!(share_preview_completed: false)
        end

        transitions from: :archived, to: :archived_with_draft
      end

      event :archive_live_form do
        transitions from: :live, to: :archived
        transitions from: :live_with_draft, to: :archived_with_draft

        after do
          Api::V2::FormDocumentSyncService.new.synchronize_form(self)
        end
      end
    end
  end
end

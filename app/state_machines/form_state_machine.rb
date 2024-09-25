module FormStateMachine
  extend ActiveSupport::Concern

  def form_sync
    Api::V2::ModelSync.new
  end

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

          form_sync.make_live(id, form_blob, aasm.from_state, external_id)
        end

        transitions from: %i[draft live_with_draft archived archived_with_draft], to: :live, guard: proc { ready_for_live }
      end

      event :create_draft_from_live_form do
        transitions from: :live, to: :live_with_draft
      end

      event :create_draft_from_archived_form do
        transitions from: :archived, to: :archived_with_draft
      end

      event :archive_live_form do
        after do
          form_blob = JSON.parse(archived_live_version)
          form_sync.archive_live_form(id, form_blob, external_id)
        end

        transitions from: :live, to: :archived
        transitions from: :live_with_draft, to: :archived_with_draft
      end
    end
  end
end

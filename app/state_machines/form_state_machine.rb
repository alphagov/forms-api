module FormStateMachine
  extend ActiveSupport::Concern

  included do
    include AASM

    enum :state, {
      draft: "draft",
      deleted: "deleted",
      live: "live",
      draft_live: "draft_live",
      archived: "archived",
      draft_archived: "draft_archived",
    }

    aasm column: :state, enum: true do
      state :draft, initial: true
      state :deleted, :live, :draft_live, :archived, :draft_archived

      event :delete_form do
        after do
          self.destroy!
        end

        transitions from: :draft, to: :deleted
      end

      event :make_live do
        after do
          live_at ||= Time.zone.now
          touch(time: live_at)

          form_blob = self.snapshot(live_at:)
          made_live_forms.create!(json_form_blob: form_blob.to_json, created_at: live_at)
        end

        transitions from: %i[draft draft_live archived draft_archived], to: :live, guard: proc { task_status_service.mandatory_tasks_completed? }
      end

      event :draft_new_live_form do
        transitions from: :live, to: :draft_live, guard: proc { has_live_version }
      end

      event :archive_live_form do
        transitions from: :live, to: :archived
        transitions from: :draft_live, to: :draft_archived
      end

      event :create_draft_from_archived_form do
        transitions from: :archived, to: :draft_archived
      end
    end

  private

    def task_status_service
      @task_status_service ||= TaskStatusService.new(form: self)
    end
  end
end

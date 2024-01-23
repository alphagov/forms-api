module FormStateMachine
  extend ActiveSupport::Concern

  included do
    include AASM

    enum :state, {
      draft: "draft",
      live: "live",
      draft_live: "draft_live",
      archived: "archived",
      draft_archived: "draft_archived",
    }

    aasm column: :state, enum: true do
      state :draft, initial: true
      state :live, :draft_live, :archived, :draft_archived
      # or written like
      # state :live
      # state :draft_live
      # state :archived
      # state :draft_archived

      event :make_live do
        after do
          live_at ||= Time.zone.now
          touch(time: live_at)

          form_blob = self.snapshot(live_at:)
          made_live_forms.create!(json_form_blob: form_blob.to_json, created_at: live_at)
        end

        transitions from: %i[draft draft_live draft_archived], to: :live, guard: proc { task_status_service.mandatory_tasks_completed? }
      end

      event :draft_new_live_form do
        transitions from: :live, to: :draft_live, guard: proc { has_live_version }
      end

      event :make_draft_changes_live do
        transitions from: %i[draft_live draft_archived], to: :live
      end

      event :archive_live_form do
        transitions from: %i[live draft_live], to: :archived, guard: proc { has_live_version }
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

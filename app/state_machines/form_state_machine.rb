module FormStateMachine
  extend ActiveSupport::Concern

  included do
    include AASM

    enum :state, {
      draft: "draft",
      deleted: "deleted",
      live: "live",
      live_with_draft: "live_with_draft",
    }

    aasm column: :state, enum: true do
      state :draft, initial: true
      state :deleted, :live, :live_with_draft

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
        end

        transitions from: %i[draft live_with_draft], to: :live, guard: proc { task_status_service.mandatory_tasks_completed? }
      end

      event :create_draft_from_live_form do
        transitions from: :live, to: :live_with_draft
      end
    end

  private

    def task_status_service
      @task_status_service ||= TaskStatusService.new(form: self)
    end
  end
end
class Api::V1::FormsController < ApplicationController
  def append_info_to_payload(payload)
    super
    payload[:form_id] = params[:id] if params[:id].present?
  end

  def index
    organisation_id = params[:organisation_id]
    creator_id = params[:creator_id]

    forms = Form.all
    forms = forms.filter_by_organisation_id(organisation_id) if organisation_id.present?
    forms = forms.filter_by_creator_id(creator_id) if creator_id.present?

    render json: forms.order(:name).to_json
  end

  def create
    new_form = Form.new(form_params)
    if new_form.save
      render json: new_form.to_json, status: :created
    else
      render json: new_form.errors.to_json, status: :bad_request
    end
  end

  def update
    if form.update(form_params)
      # TODO: https://trello.com/c/dg9CFPgp/1503-user-triggers-state-change-from-live-to-livewithdraft
      # Will not be needed when users can trigger this event themselves through the UI
      form.create_draft_from_live_form! if form.live?

      render json: form.to_json, status: :ok
    else
      render json: form.errors.to_json, status: :bad_request
    end
  end

  def show
    render json: form.to_json, status: :ok
  end

  def destroy
    form.destroy!
    render status: :no_content
  end

  def make_live
    form.make_live!
    render json: form.live_version, status: :ok
  rescue AASM::InvalidTransition
    render json: form.incomplete_tasks.to_json, status: :forbidden
  end

  def archive
    form.archive_live_form!
    render json: form, status: :ok
  rescue AASM::InvalidTransition
    render json: { error: "Form cannot be archived" }, status: :forbidden
  end

  def show_live
    render json: form.live_version, status: :ok
  end

  def show_draft
    render json: form.draft_version, status: :ok
  end

  def update_organisation_for_creator
    params.require(%i[creator_id organisation_id])
    Form.where(creator_id: params[:creator_id]).update_all(organisation_id: params[:organisation_id], updated_at: Time.zone.now)
    render status: :no_content
  end

private

  def form
    @form ||= Form.find(params.require(:id))
  end

  def form_params
    # FIXUP -  how to best list all params which form can take? List explicitly or take from model?
    # params.permit(:org, :name, :submission_email)
    params.require(:form).permit(Form.attribute_names).except(:created_at, :updated_at) # how to best list all params which form can take?
  end
end

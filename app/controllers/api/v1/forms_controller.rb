class Api::V1::FormsController < ApplicationController
  def index
    org = params[:org]
    creator_id = params[:creator_id]

    forms = Form.all
    forms = forms.filter_by_org(org) if org.present?
    forms = forms.filter_by_creator_id(creator_id) if creator_id.present?

    render json: forms.order(:name).to_json
  end

  def create
    new_form = Form.new(form_params)
    if new_form.save
      render json: { id: new_form.id }, status: :created # Fixup - just returning id here, could we return whole object?
    else
      render json: new_form.errors.to_json, status: :bad_request
    end
  end

  def update
    if form.update(form_params)
      render json: { success: true }.to_json, status: :ok
    else
      render json: form.errors.to_json, status: :bad_request
    end
  end

  def show
    render json: form.to_json, status: :ok
  end

  def destroy
    form.destroy!
    render json: { success: true }.to_json, status: :ok
  end

  def make_live
    form.make_live!
    render json: { success: true }.to_json, status: :ok
  end

  def show_live
    render json: form.live_version, status: :ok
  end

  def show_draft
    render json: form.draft_version, status: :ok
  end

  def update_org_for_creator
    params.require(%i[creator_id org])
    Form.where(creator_id: params[:creator_id]).update_all(org: params[:org], updated_at: Time.zone.now)
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

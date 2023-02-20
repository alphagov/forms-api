class Api::V1::FormsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::ParameterMissing do |exception|
    render json: { error: exception.message }, status: :bad_request
  end

  def index
    org = params.require(:org)
    render json: Form.where(org:).order(:name).to_json
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

private

  def form
    @form ||= Form.find(params.require(:id))
  end

  def form_params
    # FIXUP -  how to best list all params which form can take? List explicitly or take from model?
    # params.permit(:org, :name, :submission_email)
    params.require(:form).permit(Form.attribute_names).except(:created_at, :updated_at) # how to best list all params which form can take?
  end

  def not_found
    render json: { error: "not_found" }.to_json, status: :not_found
  end
end

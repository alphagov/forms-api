class Api::V1::FormsController < ApplicationController
  rescue_from ActionController::ParameterMissing do |exception|
    render json: { error: exception.message }, status: :bad_request
  end

  def index
    org = params.require(:org)
    render json: Form.where(org:).to_json
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
    @form = Form.find_by_id(params[:id])

    if @form
      if @form.update(form_params)
        render json: { success: true }.to_json, status: :ok
      else
        render json: @form.errors.to_json, status: :bad_request
      end
    else
      render json: { error: "not_found" }.to_json, status: :not_found
    end
  end

  def show
    @form = Form.find_by_id(params[:id])

    if @form
      render json: @form.to_json, status: :ok
    else
      render json: { error: "not_found" }.to_json, status: :not_found
    end
  end

  def destroy
    @form = Form.find_by_id(params[:id])

    if @form
      @form.destroy!
      render json: { success: true }.to_json, status: :ok
    else
      render json: { error: "not_found" }.to_json, status: :not_found
    end
  end

private

  def form_params
    # FIXUP -  how to best list all params which form can take? List explicitly or take from model?
    # params.permit(:org, :name, :submission_email)
    params.require(:form).permit(Form.attribute_names) # how to best list all params which form can take?
  end
end

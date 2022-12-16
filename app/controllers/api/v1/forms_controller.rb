class Api::V1::FormsController < ApplicationController
  rescue_from ActionController::ParameterMissing do |_exception|
    # We need to decide if we use the grape error messages, or new ones?
    # render json: { error: exception.message }, status: :bad_request
    render json: [{ messages: ["is missing"], params: %w[org] }], status: :bad_request
  end

  def index
    org = params.require(:org)
    render json: Form.where(org:).to_json
  end

  def create
    @form = Form.new(form_params)
    if @form.save
      render json: { id: @form.id }, status: :created # Fixup - just returning id here, could we return whole object?
    else
      render json: @form.errors, status: :unprocessable_entity
    end
  end

  private

  def form_params
    # FIXUP -  how to best list all params which form can take? List explicitly or take from model?
    # params.permit(:org, :name, :submission_email)
    params.permit(Form.attribute_names) # how to best list all params which form can take?
  end
end

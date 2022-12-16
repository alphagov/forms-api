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
end

class ApplicationController < ActionController::API
  before_action :set_content_type
  before_action :authenticate_request

  def set_content_type
    response.headers["Content-Type"] = "application/json"
  end

  def authenticate_request
    if Settings.forms_api.authentication_key.present? && !authenticate
      render json: { status: "unauthorised" }, status: :unauthorized
    end
  end

private

  def authenticate
    (request.headers["X-Api-Token"] == Settings.forms_api.authentication_key)
  end
end

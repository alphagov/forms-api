class ApplicationController < ActionController::API
  before_action :set_content_type
  before_action :authenticate_request

  def set_content_type
    response.headers["Content-Type"] = "application/json"
  end

  def authenticate_request
    unless request.headers["X-Api-Token"] == Settings.forms_api.authentication_key
      render json: { status: "unauthorised" }, status: :unauthorized
    end
  end
end

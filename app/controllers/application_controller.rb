class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_action :set_content_type
  before_action :authenticate_request

  def set_content_type
    response.headers["Content-Type"] = "application/json"
  end

  def authenticate_request
    return nil unless Settings.forms_api.enabled_auth

    unless authenticate_using_old_env_vars || authenticate_using_access_tokens
      render json: { status: "unauthorised" }, status: :unauthorized
    end
  end

  def append_info_to_payload(payload)
    super
    payload[:host] = request.host
    payload[:request_id] = request.request_id
    payload[:form_id] = params[:form_id] if params[:form_id].present?
  end

private

  def authenticate_using_old_env_vars
    request.headers["X-Api-Token"] == Settings.forms_api.authentication_key
  end

  def authenticate_using_access_tokens
    authenticate_with_http_token do |token|
      @user = AccessToken.active.find_by_token(Digest::SHA256.hexdigest(token))
    end
  end
end

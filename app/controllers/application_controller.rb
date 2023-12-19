class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :invalid_record
  rescue_from ActionController::ParameterMissing, with: :missing_parameter

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
    payload[:requested_by] = "#{@access_token.owner}-#{@access_token.id}" if @access_token.present?
    payload[:form_id] = params[:form_id] if params[:form_id].present?
    payload[:page_id] = params[:page_id] if params[:page_id].present?
  end

private

  def authenticate_using_old_env_vars
    return false if request.headers["X-Api-Token"].blank? || Settings.forms_api.authentication_key.blank?

    request.headers["X-Api-Token"] == Settings.forms_api.authentication_key
  end

  def authenticate_using_access_tokens
    if request.headers["X-Api-Token"].present?
      token = request.headers["X-Api-Token"]
      @access_token = AccessToken.active.find_by_token_digest(Digest::SHA256.hexdigest(token))
      if @access_token.present? && AccessTokenPolicy.new(@access_token, request).request?
        @access_token.update!(last_accessed_at: Time.zone.now)
        true
      else
        false
      end
    else
      authenticate_with_http_token do |token|
        @access_token = AccessToken.active.find_by_token_digest(Digest::SHA256.hexdigest(token))
        return unless @access_token.present? && AccessTokenPolicy.new(@access_token, request).request?

        @access_token.update!(last_accessed_at: Time.zone.now)
      end
    end
  end

  def not_found
    render json: { error: "not_found" }.to_json, status: :not_found
  end

  def missing_parameter(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  def invalid_record(resource)
    render json: resource.record.errors, status: :unprocessable_entity
  end
end

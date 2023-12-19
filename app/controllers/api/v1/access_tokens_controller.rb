class Api::V1::AccessTokensController < ApplicationController
  def index
    @access_tokens = AccessToken.all
    render json: @access_tokens.to_json, status: :ok
  end

  def create
    @access_token = AccessToken.new(token_params)
    token = @access_token.generate_token
    if @access_token.save
      render json: { **@access_token.as_json, token: }.to_json, status: :created
    else
      render json: @access_token.errors.to_json, status: :bad_request
    end
  end

  def deactivate
    @access_token = AccessToken.find(token_deactivate_params)
    @access_token.update!(deactivated_at: Time.zone.now)
    status = "`#{@access_token.owner}` has been deactivated"
    render json: { **@access_token.as_json, status: }.to_json, status: :ok
  end

  def caller_identity
    if @access_token
      render json: @access_token.to_json(except: []), status: :ok
    else
      render json: { error: "Not found - No token used." }.to_json, status: :not_found
    end
  end

private

  def token_params
    params.permit(:owner, :description, :permissions)
  end

  def token_deactivate_params
    params.require(:token_id)
  end
end

class Api::V1::AccessTokensController < ApplicationController
  def index
    @access_tokens = AccessToken.all
    render json: @access_tokens.as_json(except: [:token]).to_json, status: :ok
  end

  def create
    @access_token = AccessToken.new(token_params)
    if @access_token.save
      render json: { token: @access_token.users_token }.to_json, status: :created
    else
      render json: @access_token.errors.to_json, status: :bad_request
    end
  end

private

  def token_params
    params.permit(:owner)
  end
end

class Api::V1::FormsController < ApplicationController
  def index
    render json: {}.to_json
  end
end

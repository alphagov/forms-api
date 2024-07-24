class Api::V1::ReportsController < ApplicationController
  def features
    render json: [].to_json, status: :ok
  end
end

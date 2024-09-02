class Api::V2::FormsController < ApplicationController
  before_action :set_form, only: %i[show]

  # GET /api/v2/forms
  def index
    @forms = Api::V2::Form.all

    render json: @forms
  end

  # GET /api/v2/forms/1
  def show
    render json: @form
  end

private

  # Use callbacks to share common setup or constraints between actions.
  def set_form
    @form = Api::V2::Form.find(params[:id])
  end
end

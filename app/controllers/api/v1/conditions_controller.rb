class Api::V1::ConditionsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::ParameterMissing, with: :missing_parameter

  def index
    render json: page.routing_conditions.to_json
  end

  def create
    new_condition = page.routing_conditions.new(condition_params)

    if new_condition.save_and_update_form
      render json: { id: new_condition.id }, status: :created
    else
      render json: new_condition.errors.to_json, status: :bad_request
    end
  end

  def show
    render json: condition.to_json, status: :ok
  end

  def update
    condition.assign_attributes(condition_params)

    if condition.save_and_update_form
      render json: { success: true }.to_json, status: :ok
    else
      render json: page.errors.to_json, status: :bad_request
    end
  end

  def destroy
    condition.destroy_and_update_form!
    render json: { success: true }.to_json, status: :ok
  end

private

  def form
    @form ||= Form.find(params.require(:form_id))
  end

  def page
    @page ||= form.pages.find(params.require(:page_id))
  end

  def condition
    @condition ||= page.routing_conditions.find(params.require(:condition_id))
  end

  def condition_params
    params.require(:condition).permit(
      :id,
      :check_page_id,
      :routing_page_id,
      :goto_page_id,
      :skip_to_end,
      :answer_value,
    )
  end

  def not_found
    render json: { error: "not_found" }.to_json, status: :not_found
  end

  def missing_parameter(exception)
    render json: { error: exception.message }, status: :bad_request
  end
end

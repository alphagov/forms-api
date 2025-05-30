class Api::V1::ReportsController < ApplicationController
  def add_another_answer_forms
    data = Reports::AddAnotherAnswerUsageService.new.add_another_answer_forms

    render json: data.to_json, status: :ok
  end

  def selection_questions_summary
    statistics = Reports::SelectionQuestionService.new.live_form_statistics

    render json: statistics.to_json, status: :ok
  end

  def selection_questions_with_autocomplete
    data = Reports::SelectionQuestionService.new.live_form_pages_with_autocomplete

    render json: data.to_json, status: :ok
  end

  def selection_questions_with_radios
    data = Reports::SelectionQuestionService.new.live_form_pages_with_radios

    render json: data.to_json, status: :ok
  end

  def selection_questions_with_checkboxes
    data = Reports::SelectionQuestionService.new.live_form_pages_with_checkboxes

    render json: data.to_json, status: :ok
  end
end

class Api::V1::ReportsController < ApplicationController
  def features
    feature_stats = FeaturesReportService.new.report

    render json: feature_stats.to_json, status: :ok
  end
end

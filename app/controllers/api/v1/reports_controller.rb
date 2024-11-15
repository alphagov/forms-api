class Api::V1::ReportsController < ApplicationController
  def features
    feature_stats = Reports::FeatureUsageService.new.report

    render json: feature_stats.to_json, status: :ok
  end
end

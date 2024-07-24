require "rails_helper"

RSpec.describe Api::V1::ReportsController, type: :request do
  describe "GET /features" do
    it "returns http success" do
      get "/api/v1/reports/features"
      expect(response).to have_http_status(:success)
    end
  end
end

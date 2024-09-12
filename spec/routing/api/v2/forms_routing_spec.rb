require "rails_helper"

RSpec.describe Api::V2::FormsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/api/v2/forms").to route_to("api/v2/forms#index")
    end

    it "routes to #show" do
      expect(get: "/api/v2/forms/1").to route_to("api/v2/forms#show", id: "1")
    end
  end

  describe "path helpers" do
    it "routes using the external id" do
      form = Api::V2::Form.create! external_id: "foo"
      expect(get: api_v2_form_path(form)).to route_to("api/v2/forms#show", id: "foo")
    end
  end
end

require "rails_helper"

RSpec.describe Api::V2::FormDocumentsController, type: :routing do
  describe "routing" do
    it "routes to #show" do
      expect(get: "/api/v2/forms/1/draft").to route_to("api/v2/form_documents#show", form_id: "1", tag: "draft")
      expect(get: "/api/v2/forms/1/live").to route_to("api/v2/form_documents#show", form_id: "1", tag: "live")
      expect(get: "/api/v2/forms/1/archived").to route_to("api/v2/form_documents#show", form_id: "1", tag: "archived")
    end

    it "constrains the tag" do
      expect(get: "/api/v2/forms/1/drafts").not_to be_routable
      expect(get: "/api/v2/forms/1/alive").not_to be_routable
      expect(get: "/api/v2/forms/1/qux").not_to be_routable
    end
  end
end

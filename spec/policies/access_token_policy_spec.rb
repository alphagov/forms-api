require "rails_helper"

RSpec.describe AccessTokenPolicy do
  subject(:policy) { described_class.new(access, request) }

  let(:access) do
    build :access_token
  end

  let(:request) do
    ActionDispatch::Request.empty
  end

  describe "#request?" do
    before do
      request.headers["REQUEST_METHOD"] = request_method
    end

    context "when request method is GET" do
      let(:request_method) { "GET" }

      it "grants access if access token has all permissions" do
        access.permissions = :all

        expect(policy.request?).to be true
      end

      it "grants access if access token has readonly permissions" do
        access.permissions = :readonly

        expect(policy.request?).to be true
      end
    end

    (ActionDispatch::Request::HTTP_METHODS - %w[GET]).each do |request_method_|
      context "when request method is #{request_method_}" do
        let(:request_method) { request_method_ }

        it "grants access if access token has all permissions" do
          access.permissions = :all

          expect(policy.request?).to be true
        end

        it "denies access if access token has readonly permissions" do
          access.permissions = :readonly

          expect(policy.request?).to be false
        end
      end
    end
  end
end

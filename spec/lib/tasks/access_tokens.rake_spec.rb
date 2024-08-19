require "rake"

require "rails_helper"

RSpec.describe "access_tokens.rake" do
  before do
    Rake.application.rake_require "tasks/access_tokens"
    Rake::Task.define_task(:environment)
  end

  describe "access_tokens:remove_access_token" do
    subject(:task) do
      Rake::Task["access_tokens:remove_access_token"]
        .tap(&:reenable)
    end

    let(:token) { AccessToken.new(owner: "test-owner") }

    before do
      token.owner = "test-user@example.com"
      token.generate_token
      token.save!
    end

    it "removes an access token for a user" do
      expect { task.invoke(token.owner) }.to output(/Access token removed for test-user@example.com/).to_stdout
    end
  end
end

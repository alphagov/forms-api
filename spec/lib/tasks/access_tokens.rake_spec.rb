require "rake"

require "rails_helper"

RSpec.describe "access_tokens.rake", type: :task do
  before do
    Rake.application.rake_require "tasks/access_tokens"
    Rake::Task.define_task(:environment)
  end

  describe "access_tokens:insert" do
    subject(:task) do
      Rake::Task["access_tokens:insert"]
        .tap(&:reenable)
    end

    it "inserts an access token for the user" do
      RSpec::Matchers.define_negated_matcher :succeed, :raise_exception

      expect { task.invoke("test.user", "baa") }
        .to succeed
        .and output(/AccessToken/).to_stdout
        .and change { AccessToken.find_by(token_digest: "baa") }
        .from(nil).to(an_object_having_attributes(owner: "test.user"))
    end
  end
end

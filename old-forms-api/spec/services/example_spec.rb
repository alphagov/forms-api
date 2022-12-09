describe Repositories::ExampleRepository do
  include_context "with database"

  it "works" do
    subject = described_class.new(database)
    result = subject.test_query("name", "email")
    expect(result[:result][:name]).to eq("name")
    expect(result[:result][:submission_email]).to eq("email")
  end
end

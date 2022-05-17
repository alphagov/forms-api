describe Repositories::ExampleRepository do
  include_context "with database"

  it "works" do
    subject = described_class.new(database)
    result = subject.test_query
    expect(result[:result]).to eq(1)
  end
end

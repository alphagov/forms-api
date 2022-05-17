RSpec.shared_context "with database" do
  let(:database) { @database }

  around(:each) do |example|
    @database.transaction(rollback: :always) { example.run }
  end
end

describe Services::Example do
  it "works" do
    expect(described_class.new.execute("test"))
      .to eq("GOV.UK Forms API: test")
  end
end

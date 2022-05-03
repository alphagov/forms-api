describe Services::Example do
  it "works" do
    expect(described_class.new.get_forms("test"))
      .to eq("{\"test\":{\"item2\":{\"item3\":\"ok\"}}}")
  end
end

describe IGMarkets::Helper do
  it 'snake cases hash keys' do
    expect(IGMarkets::Helper.hash_with_snake_case_keys one: 1, twentyThree: 23).to eq(one: 1, twenty_three: 23)
  end
end

describe IGMarkets::PayloadFormatter do
  class PayloadModel < IGMarkets::Model
    attribute :the_string
    attribute :the_symbol, Symbol, allowed_values: [:two_three]
    attribute :the_date, Date, format: '%F'
  end

  it 'formats payloads correctly' do
    model = PayloadModel.new the_string: 'string', the_symbol: :two_three, the_date: Date.new(2010, 10, 20)

    expect(IGMarkets::PayloadFormatter.format(model)).to eq(theString: 'string', theSymbol: 'TWO_THREE',
                                                            theDate: '2010-10-20')
  end

  it 'camel cases snake case strings' do
    expect(IGMarkets::PayloadFormatter.snake_case_to_camel_case('one')).to eq(:one)
    expect(IGMarkets::PayloadFormatter.snake_case_to_camel_case('one_two_three')).to eq(:oneTwoThree)
  end
end

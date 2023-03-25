describe IGMarkets::CLI::Tables::ClientSentimentsTable do
  it 'prints client sentiments' do
    client_sentiments = [
      build(:client_sentiment, market_id: 'A'),
      build(:client_sentiment, market_id: 'B', long_position_percentage: 75, short_position_percentage: 25),
      build(:client_sentiment, market_id: 'C', long_position_percentage: 10, short_position_percentage: 90)
    ]

    expect(described_class.new(client_sentiments, title: 'Title').to_s).to eql(<<~MSG.strip
      +---------------------------+
      |           Title           |
      +--------+--------+---------+
      | Market | Long % | Short % |
      +--------+--------+---------+
      | A      |     60 |      40 |
      | #{ColorizedString['B'].yellow}      |     #{ColorizedString['75'].yellow} |      #{ColorizedString['25'].yellow} |
      | #{ColorizedString['C'].red}      |     #{ColorizedString['10'].red} |      #{ColorizedString['90'].red} |
      +--------+--------+---------+
    MSG
                                                                              )
  end
end

describe IGMarkets::CLI::Main do
  let(:dealing_platform) { IGMarkets::DealingPlatform.new }

  def cli
    IGMarkets::CLI::Main.new [], username: '', password: '', api_key: ''
  end

  before do
    expect(IGMarkets::CLI::Main).to receive(:begin_session).and_yield(dealing_platform)
  end

  it 'prints client sentiment' do
    sentiment = build :client_sentiment
    related_sentiments = [
      build(:client_sentiment, market_id: 'A'),
      build(:client_sentiment, market_id: 'B', long_position_percentage: 75, short_position_percentage: 25),
      build(:client_sentiment, market_id: 'C', long_position_percentage: 10, short_position_percentage: 90)
    ]

    expect(dealing_platform.client_sentiment).to receive(:[]).with('query').and_return(sentiment)
    expect(sentiment).to receive(:related_sentiments).and_return(related_sentiments)

    expect { cli.sentiment 'query' }.to output(<<-END
+----------+----------+----------+
|  Client sentiment for 'query'  |
+----------+----------+----------+
| Market   | Long %   | Short %  |
+----------+----------+----------+
| EURUSD   |       60 |       40 |
+----------+----------+----------+
| A        |       60 |       40 |
| #{'B'.yellow}        |       #{'75'.yellow} |       #{'25'.yellow} |
| #{'C'.red}        |       #{'10'.red} |       #{'90'.red} |
+----------+----------+----------+
END
                                              ).to_stdout
  end
end

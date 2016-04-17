describe IGMarkets::CLI::Main do
  let(:dealing_platform) { IGMarkets::DealingPlatform.new }

  def cli(arguments = {})
    IGMarkets::CLI::Main.new [], { username: '', password: '', api_key: '' }.merge(arguments)
  end

  before do
    expect(IGMarkets::CLI::Main).to receive(:begin_session).and_yield(dealing_platform)
  end

  it 'prints client sentiment' do
    sentiment = build(:client_sentiment)
    related_sentiments = [build(:client_sentiment, market_id: 'A'), build(:client_sentiment, market_id: 'B')]

    expect(dealing_platform.client_sentiment).to receive(:[]).with('query').and_return(sentiment)
    expect(sentiment).to receive(:related_sentiments).and_return(related_sentiments)

    expect { cli(related: true).sentiment 'query' }.to output(<<-END
EURUSD: longs: 60.0%, shorts: 40.0%
A: longs: 60.0%, shorts: 40.0%
B: longs: 60.0%, shorts: 40.0%
END
                                                             ).to_stdout
  end
end

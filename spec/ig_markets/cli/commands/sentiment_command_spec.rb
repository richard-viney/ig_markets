describe IGMarkets::CLI::Main do
  include_context 'cli_command'

  def cli
    IGMarkets::CLI::Main.new [], username: '', password: '', api_key: ''
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

    table_rows = [sentiment, :separator, related_sentiments]
    table_title = "Client sentiment for 'query'"

    expect do
      cli.sentiment 'query'
    end.to output("#{IGMarkets::CLI::ClientSentimentsTable.new table_rows, title: table_title}\n").to_stdout
  end
end

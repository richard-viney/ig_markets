describe IGMarkets::DealingPlatform::ClientSentimentMethods, :dealing_platform do
  it 'can retrieve the client sentiment for a market' do
    client_sentiment = build :client_sentiment

    expect(session).to receive(:get).with('clientsentiment/1').and_return(client_sentiment)

    expect(dealing_platform.client_sentiment['1']).to eq(client_sentiment)
  end

  it 'raises an exception for an unknown market' do
    client_sentiment = build :client_sentiment, long_position_percentage: 0, short_position_percentage: 0

    expect(session).to receive(:get).with('clientsentiment/1').and_return(client_sentiment)

    expect { dealing_platform.client_sentiment['1'] }.to raise_error(ArgumentError, "unknown market '1'")
  end

  it 'can retrieve the related client sentiments for a market' do
    client_sentiment = build :client_sentiment, market_id: '1'
    related_sentiments = [build(:client_sentiment), build(:client_sentiment)]

    expect(session).to receive(:get).with('clientsentiment/1').and_return(client_sentiment)
    expect(session).to receive(:get).with('clientsentiment/related/1').and_return(client_sentiments: related_sentiments)

    expect(dealing_platform.client_sentiment['1'].related_sentiments).to eq(related_sentiments)
  end
end

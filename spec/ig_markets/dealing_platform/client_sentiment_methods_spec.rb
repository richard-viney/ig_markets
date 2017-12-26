describe IGMarkets::DealingPlatform::ClientSentimentMethods, :dealing_platform do
  it 'retrieves the client sentiment for a market' do
    client_sentiments = [build(:client_sentiment)]

    expect(session).to receive(:get).with('clientsentiment?marketIds=1').and_return(client_sentiments: client_sentiments)

    expect(dealing_platform.client_sentiment['1']).to eq(client_sentiments.first)
  end

  it 'retrieves the client sentiment for multiple market' do
    client_sentiments = [build(:client_sentiment), build(:client_sentiment)]

    expect(session).to receive(:get).with('clientsentiment?marketIds=1,2').and_return(client_sentiments: client_sentiments)

    expect(dealing_platform.client_sentiment.find('1', '2')).to eq(client_sentiments)
  end

  it 'raises on an unknown market' do
    client_sentiments = [build(:client_sentiment, market_id: '1', long_position_percentage: 0, short_position_percentage: 0)]

    expect(session).to receive(:get).with('clientsentiment?marketIds=1').and_return(client_sentiments: client_sentiments)

    expect { dealing_platform.client_sentiment['1'] }.to raise_error(ArgumentError, "unknown market '1'")
  end

  it 'retrieves the related client sentiments for a market' do
    client_sentiments = [build(:client_sentiment, market_id: '1')]
    related_sentiments = [build(:client_sentiment), build(:client_sentiment)]

    expect(session).to receive(:get).with('clientsentiment?marketIds=1').and_return(client_sentiments: client_sentiments)
    expect(session).to receive(:get).with('clientsentiment/related/1').and_return(client_sentiments: related_sentiments)

    expect(dealing_platform.client_sentiment['1'].related_sentiments).to eq(related_sentiments)
  end
end

describe IGMarkets::DealingPlatform::ClientSentimentMethods do
  let(:session) { IGMarkets::Session.new }
  let(:platform) do
    IGMarkets::DealingPlatform.new.tap do |platform|
      platform.instance_variable_set :@session, session
    end
  end

  it 'can retrieve the client sentiment for a market' do
    client_sentiment = build :client_sentiment

    expect(session).to receive(:get).with('clientsentiment/1', IGMarkets::API_V1).and_return(client_sentiment)

    expect(platform.client_sentiment['1']).to eq(client_sentiment)
  end

  it 'can retrieve the related client sentiments for a market' do
    client_sentiment = build :client_sentiment, market_id: '1'
    related_client_sentiments = [build(:client_sentiment), build(:client_sentiment)]

    expect(session).to receive(:get).with('clientsentiment/1', IGMarkets::API_V1).and_return(client_sentiment)

    expect(session).to receive(:get)
      .with('clientsentiment/related/1', IGMarkets::API_V1)
      .and_return(client_sentiments: related_client_sentiments)

    expect(platform.client_sentiment['1'].related_sentiments).to eq(related_client_sentiments)
  end
end

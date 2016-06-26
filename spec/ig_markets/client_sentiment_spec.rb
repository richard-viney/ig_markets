describe IGMarkets::ClientSentiment do
  include_context 'dealing_platform'

  let(:client_sentiment) { dealing_platform_model build(:client_sentiment, market_id: '1') }

  it 'reloads its attributes' do
    expect(dealing_platform.client_sentiment).to receive(:[]).with('1').twice.and_return(client_sentiment)

    client_sentiment_copy = dealing_platform.client_sentiment['1'].dup
    client_sentiment_copy.long_position_percentage = 0
    client_sentiment_copy.reload

    expect(client_sentiment_copy.long_position_percentage).to eq(60)
  end

  it 'requests related sentiments' do
    related_sentiments = [build(:client_sentiment), build(:client_sentiment)]

    expect(session).to receive(:get).with('clientsentiment/related/1').and_return(client_sentiments: related_sentiments)

    client_sentiment.related_sentiments
  end
end

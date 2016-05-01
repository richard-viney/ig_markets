describe IGMarkets::ClientSentiment do
  include_context 'dealing_platform'

  let(:client_sentiment) { dealing_platform_model build(:client_sentiment, market_id: '1') }

  it 'requests related sentiments' do
    related_sentiments = [build(:client_sentiment), build(:client_sentiment)]

    expect(session).to receive(:get).with('clientsentiment/related/1').and_return(client_sentiments: related_sentiments)

    client_sentiment.related_sentiments
  end
end

FactoryGirl.define do
  factory :client_sentiment, class: IGMarkets::ClientSentiment do
    long_position_percentage 60.0
    market_id 'EURUSD'
    short_position_percentage 40.0
  end
end

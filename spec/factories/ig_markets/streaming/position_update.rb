FactoryBot.define do
  factory :streaming_position_update, class: 'IGMarkets::Streaming::PositionUpdate' do
    account_id { 'ACCOUNT' }
    channel { 'web' }
    currency { 'USD' }
    deal_id { 'DEAL' }
    deal_id_origin { 'DEAL2' }
    deal_reference { 'reference' }
    deal_status { 'ACCEPTED' }
    direction { 'BUY' }
    epic { 'CS.D.EURUSD.CFD.IP' }
    expiry { '-' }
    guaranteed_stop { false }
    level { 1.1 }
    limit_level { 1.2 }
    size { 5 }
    status { 'OPEN' }
    stop_level { 1.0 }
    timestamp { '2015-12-15T15:00:00.123' }
  end
end

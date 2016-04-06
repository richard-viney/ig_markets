module IGMarkets
  # Contains details on a sprint market position. Returned by {DealingPlatform::SprintMarketPositionMethods#all}.
  class SprintMarketPosition < Model
    attribute :created_date, DateTime, format: '%Y/%m/%d %H:%M:%S:%L'
    attribute :currency, String, regex: Regex::CURRENCY
    attribute :deal_id
    attribute :description
    attribute :direction, Symbol, allowed_values: [:buy, :sell]
    attribute :epic, String, regex: Regex::EPIC
    attribute :expiry_time, DateTime, format: '%Y/%m/%d %H:%M:%S:%L'
    attribute :instrument_name
    attribute :market_status, Symbol, allowed_values: Market::Snapshot.allowed_values(:market_status)
    attribute :payout_amount, Float
    attribute :size, Fixnum
    attribute :strike_level, Float
  end
end

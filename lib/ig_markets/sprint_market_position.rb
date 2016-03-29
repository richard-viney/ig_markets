module IGMarkets
  class SprintMarketPosition < Model
    attribute :created_date, DateTime, format: '%Y/%m/%d %H:%M:%S:%L'
    attribute :currency, String, regex: Validate::CURRENCY_REGEX
    attribute :deal_id
    attribute :description
    attribute :direction, Symbol, allowed_values: [:buy, :sell]
    attribute :epic, String, regex: Validate::EPIC_REGEX
    attribute :expiry_time, DateTime, format: '%Y/%m/%d %H:%M:%S:%L'
    attribute :instrument_name
    attribute :market_status, Symbol, allowed_values: Market.defined_attributes[:market_status][:allowed_values]
    attribute :payout_amount, Float
    attribute :size, Float
    attribute :strike_level, Float
  end
end

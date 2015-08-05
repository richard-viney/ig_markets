module IGMarkets
  class SprintMarketPosition < Model
    attribute :created_date, typecaster: AttributeTypecasters.date_time('%Y-%m-%d')
    attribute :currency
    attribute :deal_id
    attribute :description
    attribute :direction
    attribute :epic
    attribute :expiry_time
    attribute :instrument_name
    attribute :market_status
    attribute :payout_amount, typecaster: AttributeTypecasters.float
    attribute :size, typecaster: AttributeTypecasters.float
    attribute :strike_level, typecaster: AttributeTypecasters.float
  end
end

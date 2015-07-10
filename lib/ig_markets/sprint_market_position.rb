module IGMarkets
  class SprintMarketPosition < Model
    attribute :created_date, type: DateTime
    attribute :currency
    attribute :deal_id
    attribute :description
    attribute :direction
    attribute :epic
    attribute :expiry_time
    attribute :instrument_name
    attribute :market_status
    attribute :payout_amount, type: Float
    attribute :size, type: Float
    attribute :strike_level, type: Float
  end
end

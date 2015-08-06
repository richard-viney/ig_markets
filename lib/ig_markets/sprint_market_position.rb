module IGMarkets
  class SprintMarketPosition < Model
    attribute :created_date, type: :date_time, format: '%Y-%m-%d'
    attribute :currency
    attribute :deal_id
    attribute :description
    attribute :direction
    attribute :epic
    attribute :expiry_time
    attribute :instrument_name
    attribute :market_status
    attribute :payout_amount, type: :float
    attribute :size, type: :float
    attribute :strike_level, type: :float
  end
end

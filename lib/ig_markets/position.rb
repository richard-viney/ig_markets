module IGMarkets
  class Position
    include ActiveAttr::Model

    attribute :contract_size, type: Float
    attribute :controlled_risk, type: Boolean
    attribute :created_date, type: DateTime
    attribute :currency
    attribute :deal_id
    attribute :deal_size, type: Float
    attribute :direction
    attribute :limit_level, type: Float
    attribute :open_level, type: Float
    attribute :stop_level, type: Float
    attribute :trailing_step, type: Float
    attribute :trailing_stop_distance, type: Float

    attribute :market, typecaster: proc { |attributes| Market.new attributes }
  end
end

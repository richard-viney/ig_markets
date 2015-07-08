module IGMarkets
  class WorkingOrder
    include ActiveAttr::Model

    attribute :created_date, type: DateTime
    attribute :currency_code
    attribute :deal_id
    attribute :direction
    attribute :dma, type: Boolean
    attribute :epic
    attribute :good_till_date, type: DateTime
    attribute :guaranteed_stop, type: Boolean
    attribute :limit_distance, type: Float
    attribute :order_level, type: Float
    attribute :order_size, type: Float
    attribute :order_type
    attribute :stop_distance, type: Float
    attribute :time_in_force

    attribute :market, typecaster: AttributeTypecasters.market
  end
end

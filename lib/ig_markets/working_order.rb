module IGMarkets
  class WorkingOrder < Model
    attribute :created_date, typecaster: AttributeTypecasters.date_time('%Y/%m/%d %H:%M:%S:%L')
    attribute :currency_code
    attribute :deal_id
    attribute :direction
    attribute :dma, typecaster: AttributeTypecasters.boolean
    attribute :epic
    attribute :good_till_date, typecaster: AttributeTypecasters.date_time('%Y/%m/%d %H:%M')
    attribute :guaranteed_stop, typecaster: AttributeTypecasters.boolean
    attribute :limit_distance, typecaster: AttributeTypecasters.float
    attribute :order_level, typecaster: AttributeTypecasters.float
    attribute :order_size, typecaster: AttributeTypecasters.float
    attribute :order_type
    attribute :stop_distance, typecaster: AttributeTypecasters.float
    attribute :time_in_force

    attribute :market, typecaster: AttributeTypecasters.market
  end
end

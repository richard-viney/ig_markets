module IGMarkets
  class Position < Model
    attribute :contract_size, typecaster: AttributeTypecasters.float
    attribute :controlled_risk, typecaster: AttributeTypecasters.boolean
    attribute :created_date, typecaster: AttributeTypecasters.date_time('%d-%m-%Y')
    attribute :currency
    attribute :deal_id
    attribute :direction
    attribute :level, typecaster: AttributeTypecasters.float
    attribute :limit_level, typecaster: AttributeTypecasters.float
    attribute :size, typecaster: AttributeTypecasters.float
    attribute :stop_level, typecaster: AttributeTypecasters.float
    attribute :trailing_step, typecaster: AttributeTypecasters.float
    attribute :trailing_stop_distance, typecaster: AttributeTypecasters.float

    attribute :market, typecaster: AttributeTypecasters.market
  end
end

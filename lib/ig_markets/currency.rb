module IGMarkets
  class Currency < Model
    attribute :base_exchange_rate, typecaster: AttributeTypecasters.float
    attribute :code
    attribute :exchange_rate, typecaster: AttributeTypecasters.float
    attribute :is_default, typecaster: AttributeTypecasters.boolean
    attribute :symbol
  end
end

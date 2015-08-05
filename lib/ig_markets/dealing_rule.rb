module IGMarkets
  class DealingRule < Model
    attribute :unit
    attribute :value, typecaster: AttributeTypecasters.float
  end
end

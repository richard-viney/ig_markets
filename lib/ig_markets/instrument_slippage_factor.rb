module IGMarkets
  class InstrumentSlippageFactor < Model
    attribute :unit
    attribute :value, typecaster: AttributeTypecasters.float
  end
end

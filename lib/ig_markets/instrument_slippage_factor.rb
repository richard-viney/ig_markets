module IGMarkets
  class InstrumentSlippageFactor < Model
    attribute :unit
    attribute :value, type: Float
  end
end

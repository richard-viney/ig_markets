module IGMarkets
  class InstrumentSlippageFactor < Model
    attribute :unit
    attribute :value, type: :float
  end
end

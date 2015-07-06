module IGMarkets
  class InstrumentSlippageFactor
    include ActiveAttr::Model

    attribute :unit
    attribute :value, type: Float
  end
end

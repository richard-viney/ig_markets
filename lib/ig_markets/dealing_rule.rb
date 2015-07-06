module IGMarkets
  class DealingRule
    include ActiveAttr::Model

    attribute :unit
    attribute :value, type: Float
  end
end

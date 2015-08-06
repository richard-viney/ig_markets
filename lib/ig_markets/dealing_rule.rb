module IGMarkets
  class DealingRule < Model
    attribute :unit
    attribute :value, type: :float
  end
end

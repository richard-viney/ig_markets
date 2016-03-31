module IGMarkets
  class DealingRule < Model
    attribute :unit, Symbol, allowed_values: [:percentage, :points]
    attribute :value, Float
  end
end

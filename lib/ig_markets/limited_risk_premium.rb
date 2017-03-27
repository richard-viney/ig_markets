module IGMarkets
  # Contains details on a limited risk premium. Returned by {Instrument#limited_risk_premium},
  # {Position#limited_risk_premium} and {WorkingOrder#limited_risk_premium}.
  class LimitedRiskPremium < Model
    attribute :unit, Symbol, allowed_values: %i(percentage points)
    attribute :value, Float
  end
end

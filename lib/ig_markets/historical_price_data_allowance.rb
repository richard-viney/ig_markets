module IGMarkets
  class HistoricalPriceDataAllowance < Model
    attribute :allowance_expiry, typecaster: AttributeTypecasters.float
    attribute :remaining_allowance, typecaster: AttributeTypecasters.float
    attribute :total_allowance, typecaster: AttributeTypecasters.float
  end
end

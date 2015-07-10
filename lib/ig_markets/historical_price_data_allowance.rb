module IGMarkets
  class HistoricalPriceDataAllowance < Model
    attribute :allowance_expiry, type: Float
    attribute :remaining_allowance, type: Float
    attribute :total_allowance, type: Float
  end
end

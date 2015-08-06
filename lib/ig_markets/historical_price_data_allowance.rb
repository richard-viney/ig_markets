module IGMarkets
  class HistoricalPriceDataAllowance < Model
    attribute :allowance_expiry, type: :float
    attribute :remaining_allowance, type: :float
    attribute :total_allowance, type: :float
  end
end

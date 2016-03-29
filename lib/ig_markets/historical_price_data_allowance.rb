module IGMarkets
  class HistoricalPriceDataAllowance < Model
    attribute :allowance_expiry, Fixnum
    attribute :remaining_allowance, Fixnum
    attribute :total_allowance, Fixnum
  end
end

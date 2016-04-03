module IGMarkets
  # Contains details on the remaining allowance for looking up historical prices. Returned by {Market#recent_prices} and
  # {Market#prices_in_date_range}.
  class HistoricalPriceDataAllowance < Model
    attribute :allowance_expiry, Fixnum
    attribute :remaining_allowance, Fixnum
    attribute :total_allowance, Fixnum
  end
end

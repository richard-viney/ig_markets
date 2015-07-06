module IGMarkets
  class HistoricalPriceDataAllowance
    include ActiveAttr::Model

    attribute :allowance_expiry, type: Float
    attribute :remaining_allowance, type: Float
    attribute :total_allowance, type: Float
  end
end

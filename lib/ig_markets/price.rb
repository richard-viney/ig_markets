module IGMarkets
  class Price < Model
    attribute :ask, type: Float
    attribute :bid, type: Float
    attribute :last_traded, type: Float
  end
end

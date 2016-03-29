module IGMarkets
  class Price < Model
    attribute :ask, Float
    attribute :bid, Float
    attribute :last_traded, Float
  end
end

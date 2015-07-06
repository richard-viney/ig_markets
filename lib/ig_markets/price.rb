module IGMarkets
  class Price
    include ActiveAttr::Model

    attribute :ask, type: Float
    attribute :bid, type: Float
    attribute :last_traded, type: Float
  end
end

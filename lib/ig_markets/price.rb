module IGMarkets
  class Price < Model
    attribute :ask, typecaster: AttributeTypecasters.float
    attribute :bid, typecaster: AttributeTypecasters.float
    attribute :last_traded, typecaster: AttributeTypecasters.float
  end
end

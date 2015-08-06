module IGMarkets
  class Price < Model
    attribute :ask, type: :float
    attribute :bid, type: :float
    attribute :last_traded, type: :float
  end
end

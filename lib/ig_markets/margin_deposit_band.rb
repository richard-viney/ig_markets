module IGMarkets
  class MarginDepositBand < Model
    attribute :currency
    attribute :margin, typecaster: AttributeTypecasters.float
    attribute :max, typecaster: AttributeTypecasters.float
    attribute :min, typecaster: AttributeTypecasters.float
  end
end

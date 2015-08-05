module IGMarkets
  class AccountBalance < Model
    attribute :available, typecaster: AttributeTypecasters.float
    attribute :balance, typecaster: AttributeTypecasters.float
    attribute :deposit, typecaster: AttributeTypecasters.float
    attribute :profit_loss, typecaster: AttributeTypecasters.float
  end
end

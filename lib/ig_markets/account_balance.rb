module IGMarkets
  class AccountBalance < Model
    attribute :available, type: Float
    attribute :balance, type: Float
    attribute :deposit, type: Float
    attribute :profit_loss, type: Float
  end
end

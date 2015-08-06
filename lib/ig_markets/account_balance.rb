module IGMarkets
  class AccountBalance < Model
    attribute :available, type: :float
    attribute :balance, type: :float
    attribute :deposit, type: :float
    attribute :profit_loss, type: :float
  end
end

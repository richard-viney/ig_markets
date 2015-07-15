FactoryGirl.define do
  factory :account_balance, class: IGMarkets::AccountBalance do
    available 0.0
    balance 0.0
    deposit 0.0
    profit_loss 0.0
  end
end

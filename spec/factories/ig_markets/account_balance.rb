FactoryGirl.define do
  factory :account_balance, class: IGMarkets::Account::Balance do
    available 500.0
    balance 500.0
    deposit 0.0
    profit_loss 0.0
  end
end

FactoryGirl.define do
  factory :account_balance, class: IGMarkets::Account::Balance do
    available 5000.0
    balance 5000.0
    deposit 0.0
    profit_loss 0.0
  end
end

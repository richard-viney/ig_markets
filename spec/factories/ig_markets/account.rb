FactoryGirl.define do
  factory :account, class: IGMarkets::Account do
    account_alias 'Alias'
    account_id 'ACCOUNT'
    account_name 'CFD'
    account_type 'CFD'
    balance { build :account_balance }
    can_transfer_from true
    can_transfer_to true
    currency 'USD'
    preferred true
    status 'ENABLED'
  end
end

FactoryGirl.define do
  factory :account_balance, class: IGMarkets::Account::Balance do
    available 500.0
    balance 500.0
    deposit 0.0
    profit_loss 0.0
  end
end

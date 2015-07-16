FactoryGirl.define do
  factory :account, class: IGMarkets::Account do
    account_alias 'alias'
    account_id 'A1234'
    account_name 'CFD'
    account_type 'CFD'
    balance { build(:account_balance) }
    can_transfer_from true
    can_transfer_to true
    currency 'USD'
    preferred true
    status 'ENABLED'
  end
end

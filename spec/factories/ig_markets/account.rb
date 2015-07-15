FactoryGirl.define do
  factory :account, class: IGMarkets::Account do
    account_alias 'alias'
    account_id 'id'
    account_name 'name'
    account_type 'type'
    balance { build(:account_balance) }
    can_transfer_from true
    can_transfer_to true
    currency 'USD'
    preferred true
    status 'status'
  end
end

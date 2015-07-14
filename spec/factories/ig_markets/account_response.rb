FactoryGirl.define do
  factory :account_response, class: Hash do
    accountAlias 'alias'
    accountId 'id'
    accountName 'name'
    accountType 'type'
    balance(available: 0.0, balance: 0.0, deposit: 0.0, profitLoss: 0.0)
    canTransferFrom true
    canTransferTo true
    currency 'USD'
    preferred true
    status 'status'

    initialize_with { attributes }
  end
end

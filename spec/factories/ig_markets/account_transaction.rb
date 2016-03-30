FactoryGirl.define do
  factory :account_transaction, class: IGMarkets::AccountTransaction do
    cash_transaction false
    close_level '0.8'
    currency 'US'
    date '23/06/15'
    instrument_name 'instrument'
    open_level '0.8'
    period '-'
    profit_and_loss '0.0'
    reference 'reference'
    size '+1'
    transaction_type 'DEAL'
  end
end

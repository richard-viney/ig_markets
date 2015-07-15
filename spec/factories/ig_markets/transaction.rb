FactoryGirl.define do
  factory :transaction, class: IGMarkets::Transaction do
    cash_transaction true
    close_level '100.0'
    currency 'USD'
    date '20-01-2015'
    instrument_name 'instrument'
    open_level '100.0'
    period '10000'
    profit_and_loss '0.0'
    reference 'reference'
    size '+1'
    transaction_type 'DEAL'
  end
end

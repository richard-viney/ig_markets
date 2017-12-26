FactoryBot.define do
  factory :transaction, class: IGMarkets::Transaction do
    cash_transaction false
    close_level '0.8'
    currency 'US'
    date '2015-10-27'
    date_utc '2015-10-27T14:30:00'
    instrument_name 'Instrument'
    open_date_utc '2015-10-26T09:30:00'
    open_level '0.8'
    period '-'
    profit_and_loss 'US-1.00'
    reference 'reference'
    size '+1'
    transaction_type 'DEAL'
  end
end

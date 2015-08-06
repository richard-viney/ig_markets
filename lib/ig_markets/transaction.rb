module IGMarkets
  class Transaction < Model
    attribute :cash_transaction, type: :boolean
    attribute :close_level
    attribute :currency
    attribute :date, type: :date_time, format: '%d/%m/%y'
    attribute :instrument_name
    attribute :open_level
    attribute :period
    attribute :profit_and_loss
    attribute :reference
    attribute :size
    attribute :transaction_type
  end
end

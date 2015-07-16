module IGMarkets
  class Transaction < Model
    attribute :cash_transaction, type: Boolean
    attribute :close_level
    attribute :currency
    attribute :date, typecaster: AttributeTypecasters.date_time('%d/%m/%y', Date)
    attribute :instrument_name
    attribute :open_level
    attribute :period
    attribute :profit_and_loss
    attribute :reference
    attribute :size
    attribute :transaction_type
  end
end

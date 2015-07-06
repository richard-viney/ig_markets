module IGMarkets
  class Transaction
    include ActiveAttr::Model

    attribute :cash_transaction, type: Boolean
    attribute :close_level
    attribute :currency
    attribute :date, type: Date
    attribute :instrument_name
    attribute :open_level
    attribute :period
    attribute :profit_and_loss
    attribute :reference
    attribute :size
    attribute :transaction_type
  end
end

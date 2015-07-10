module IGMarkets
  class Account < Model
    attribute :account_alias
    attribute :account_id
    attribute :account_name
    attribute :account_type
    attribute :balance, typecaster: AttributeTypecasters.account_balance
    attribute :can_transfer_from, type: Boolean
    attribute :can_transfer_to, type: Boolean
    attribute :currency
    attribute :preferred, type: Boolean
    attribute :status
  end
end

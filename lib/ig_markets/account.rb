module IGMarkets
  class Account < Model
    attribute :account_alias
    attribute :account_id
    attribute :account_name
    attribute :account_type
    attribute :balance, typecaster: AttributeTypecasters.account_balance
    attribute :can_transfer_from, typecaster: AttributeTypecasters.boolean
    attribute :can_transfer_to, typecaster: AttributeTypecasters.boolean
    attribute :currency
    attribute :preferred, typecaster: AttributeTypecasters.boolean
    attribute :status
  end
end

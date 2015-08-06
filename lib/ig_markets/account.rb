module IGMarkets
  class Account < Model
    attribute :account_alias
    attribute :account_id
    attribute :account_name
    attribute :account_type
    attribute :balance, type: :account_balance
    attribute :can_transfer_from, type: :boolean
    attribute :can_transfer_to, type: :boolean
    attribute :currency
    attribute :preferred, type: :boolean
    attribute :status
  end
end

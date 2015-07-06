module IGMarkets
  class Account
    include ActiveAttr::Model

    attribute :account_alias
    attribute :account_id
    attribute :account_name
    attribute :account_type
    attribute :balance, typecaster: proc { |attributes| IGMarkets::AccountBalance.new attributes }
    attribute :can_transfer_from, type: Boolean
    attribute :can_transfer_to, type: Boolean
    attribute :currency
    attribute :preferred, type: Boolean
    attribute :status
  end
end

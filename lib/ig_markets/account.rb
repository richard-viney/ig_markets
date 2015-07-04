module IGMarkets
  class Account
    include ActiveAttr::Model

    attribute :account_alias
    attribute :account_id
    attribute :account_name
    attribute :account_type
    attribute :balance
    attribute :can_transfer_from, type: Boolean
    attribute :can_transfer_to, type: Boolean
    attribute :currency
    attribute :preferred, type: Boolean
    attribute :status

    def initialize(options = {})
      self.attributes = Helper.hash_with_snake_case_keys(options)

      self.balance = AccountBalance.new(balance)
    end
  end
end

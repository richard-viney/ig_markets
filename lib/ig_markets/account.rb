module IGMarkets
  # Contains details on an IG Markets account. Returned by {DealingPlatform::AccountMethods#all}.
  class Account < Model
    # Contains details on the balance of an {Account}, used by {Account#balance}.
    class Balance < Model
      attribute :available, Float
      attribute :balance, Float
      attribute :deposit, Float
      attribute :profit_loss, Float
    end

    attribute :account_alias
    attribute :account_id
    attribute :account_name
    attribute :account_type, Symbol, allowed_values: [:cfd, :physical, :spreadbet]
    attribute :balance, Balance
    attribute :can_transfer_from, Boolean
    attribute :can_transfer_to, Boolean
    attribute :currency, String, regex: Validate::CURRENCY_REGEX
    attribute :preferred, Boolean
    attribute :status, Symbol, allowed_values: [:disabled, :enabled, :suspended_from_dealing]
  end
end

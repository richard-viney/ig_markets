module IGMarkets
  # Contains details on a single transaction that occurred on an IG Markets account. Returned by
  # {DealingPlatform::AccountMethods#transactions}.
  class Transaction < Model
    attribute :cash_transaction, Boolean
    attribute :close_level, String, nil_if: %w[- 0]
    attribute :currency
    attribute :date_utc, Time, format: '%FT%T'
    attribute :instrument_name
    attribute :open_date_utc, Time, format: '%FT%T'
    attribute :open_level, String, nil_if: %w[- 0]
    attribute :period, Time, nil_if: %w[- DFB], format: ['%FT%T', '%d-%b-%y', '%b-%y']
    attribute :profit_and_loss
    attribute :reference
    attribute :size, String, nil_if: '-'
    attribute :transaction_type, Symbol, allowed_values: %i[chart deal depo dividend exchange trade with]

    deprecated_attribute :date

    # Returns whether or not this transaction was an interest payment. Interest payments can be either deposits or
    # withdrawals depending on the underlying instrument and currencies involved. Interest payments are identified by
    # the presence of the word `interest` in {#instrument_name}.
    #
    # @return [Boolean]
    def interest?
      %i[depo with].include?(transaction_type) && !(instrument_name.downcase =~ /(^|[^a-z])interest([^a-z]|$)/).nil?
    end

    # Returns this transaction's {#profit_and_loss} as a `Float`, denominated in this transaction's {#currency}.
    #
    # @return [Float]
    def profit_and_loss_amount
      raise 'profit_and_loss does not start with the expected currency' unless profit_and_loss.start_with? currency

      profit_and_loss[currency.length..-1].delete(',').to_f
    end
  end
end

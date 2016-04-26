module IGMarkets
  # Contains details on a sprint market position. Returned by {DealingPlatform::SprintMarketPositionMethods#all}.
  class SprintMarketPosition < Model
    attribute :created_date, Time, format: '%Y/%m/%d %T:%L', time_zone: -> { @dealing_platform.account_time_zone }
    attribute :currency, String, regex: Regex::CURRENCY
    attribute :deal_id
    attribute :description
    attribute :direction, Symbol, allowed_values: [:buy, :sell]
    attribute :epic, String, regex: Regex::EPIC
    attribute :expiry_time, Time, format: '%Y/%m/%d %T:%L', time_zone: -> { @dealing_platform.account_time_zone }
    attribute :instrument_name
    attribute :market_status, Symbol, allowed_values: Market::Snapshot.allowed_values(:market_status)
    attribute :payout_amount, Float
    attribute :size, Float
    attribute :strike_level, Float

    # Returns the number of seconds till when this sprint market position expires. This will be a negative number if
    # this sprint market position has expired.
    #
    # @return [Fixnum]
    def seconds_till_expiry
      (expiry_time - Time.now).to_i
    end

    # Returns whether this sprint market position has expired.
    #
    # @return [Boolean]
    def expired?
      expiry_time < Time.now
    end
  end
end

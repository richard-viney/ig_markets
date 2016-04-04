module IGMarkets
  # Contains details on a trading position. See {DealingPlatform::PositionMethods#all} for usage details.
  class Position < Model
    attribute :contract_size, Float
    attribute :controlled_risk, Boolean
    attribute :created_date, DateTime, format: '%Y/%m/%d %H:%M:%S:%L'
    attribute :created_date_utc, DateTime, format: '%Y-%m-%dT%H:%M:%S'
    attribute :currency, String, regex: Regex::CURRENCY
    attribute :deal_id
    attribute :direction, Symbol, allowed_values: [:buy, :sell]
    attribute :level, Float
    attribute :limit_level, Float
    attribute :size, Float
    attribute :stop_level, Float
    attribute :trailing_step, Float
    attribute :trailing_stop_distance, Fixnum

    attribute :market, MarketOverview

    # Returns whether this position has a trailing stop.
    def trailing_stop?
      !trailing_step.nil? && !trailing_stop_distance.nil?
    end

    # Updates this position. No attributes are mandatory, and any attributes not specified will be kept at their
    # current value.
    #
    # @param [Hash] new_attributes The attributes of this position to update.
    # @option new_attributes [Float] :limit_level The new limit level for this position.
    # @option new_attributes [Float] :stop_level The new stop level for this position.
    # @option new_attributes [Boolean] :trailing_stop Whether to use a trailing stop for this position.
    # @option new_attributes [Fixnum] :trailing_stop_distance Distance away in pips to place the trailing stop.
    # @option new_attributes [Fixnum] :trailing_stop_increment Step increment to use for the trailing stop.
    #
    # @return [String] The deal reference of the update operation. Use {DealingPlatform#deal_confirmation} to check
    #         the result of the position update.
    def update(new_attributes)
      new_attributes = { limit_level: limit_level, stop_level: stop_level, trailing_stop: trailing_stop?,
                         trailing_stop_distance: trailing_stop_distance, trailing_stop_increment: trailing_step
                       }.merge new_attributes

      unless new_attributes[:trailing_stop]
        new_attributes[:trailing_stop_distance] = new_attributes[:trailing_stop_increment] = nil
      end

      payload = PayloadFormatter.format PositionUpdateAttributes.new new_attributes

      @dealing_platform.session.put("positions/otc/#{deal_id}", payload, API_V2).fetch(:deal_reference)
    end

    # Internal model used by {#update}.
    class PositionUpdateAttributes < Model
      attribute :limit_level, Float
      attribute :stop_level, Float
      attribute :trailing_stop, Boolean
      attribute :trailing_stop_distance, Fixnum
      attribute :trailing_stop_increment, Fixnum
    end

    private_constant :PositionUpdateAttributes
  end
end

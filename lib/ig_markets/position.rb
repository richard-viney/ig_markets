module IGMarkets
  # Contains details on a trading position. Returned by {DealingPlatform::PositionMethods#all} and
  # {DealingPlatform::PositionMethods#[]}.
  class Position < Model
    attribute :contract_size, Float
    attribute :controlled_risk, Boolean
    attribute :created_date_utc, Time, format: '%FT%T'
    attribute :currency, String, regex: Regex::CURRENCY
    attribute :deal_id
    attribute :deal_reference
    attribute :direction, Symbol, allowed_values: [:buy, :sell]
    attribute :level, Float
    attribute :limit_level, Float
    attribute :size, Float
    attribute :stop_level, Float
    attribute :trailing_step, Float
    attribute :trailing_stop_distance, Integer

    attribute :market, MarketOverview

    deprecated_attribute :created_date

    # Returns whether this position has a trailing stop.
    def trailing_stop?
      !trailing_step.nil? && !trailing_stop_distance.nil?
    end

    # Returns the level at which this position would close at given the current market price as stored in {#market}.
    #
    # @return [Float]
    def close_level
      { buy: market.bid, sell: market.offer }.fetch direction
    end

    # Returns the favorable difference in the price between {#level} and the current market price as stored in
    # {#market}. If {#direction} is `:buy` and the market has since risen then this method will return a positive value,
    # but if {#direction} is `:sell` and the market has since risen then this method will return a negative value.
    #
    # @return [Float]
    def price_delta
      if direction == :buy
        close_level - level
      elsif direction == :sell
        level - close_level
      end
    end

    # Returns whether this position is currently profitable based on the current market state as stored in {#market}.
    def profitable?
      price_delta > 0.0
    end

    # Returns this position's current profit or loss, denominated in its {#currency}, and based on the current market
    # state as stored in {#market}. For binary instruments this returns the payout amount.
    #
    # @return [Float]
    def profit_loss
      return size / level if market.instrument_type == :binary

      price_delta * size * contract_size
    end

    # Reloads this position's attributes by re-querying the IG Markets API.
    def reload
      self.attributes = @dealing_platform.positions[deal_id].attributes
    end

    # Closes this position. If called with no options then this position will be fully closed at current market prices,
    # partial closes and greater control over the close conditions can be achieved by using the relevant options.
    #
    # @param [Hash] options The options for the position close.
    # @option options [Float] :level Required if and only if `:order_type` is `:limit` or `:quote`.
    # @option options [:limit, :market, :quote] :order_type The order type. `:market` indicates to fill the order at
    #                 current market level(s). `:limit` indicates to fill at the price specified by `:level` (or a more
    #                 favorable one). `:quote` is only permitted following agreement with IG Markets. Defaults to
    #                 `:market`.
    # @option options [String] :quote_id The Lightstreamer quote ID. Required when `:order_type` is `:quote`.
    # @option options [Float] :size The size of the position to close. Defaults to {#size} which will close the entire
    #                 position, or alternatively specify a smaller value to partially close this position.
    # @option options [:execute_and_eliminate, :fill_or_kill] :time_in_force The order fill strategy.
    #                 `:execute_and_eliminate` will fill this order as much as possible within the constraints set by
    #                 `:order_type`, `:level` and `:quote_id`. `:fill_or_kill` will try to fill this entire order within
    #                 the constraints, however if this is not possible then the order will not be filled at all. If
    #                 `:order_type` is `:market` (the default) then `:time_in_force` will be automatically set to
    #                 `:execute_and_eliminate`.
    #
    # @return [String] The resulting deal reference, use {DealingPlatform#deal_confirmation} to check the result of
    #         the position close.
    def close(options = {})
      options[:deal_id] = deal_id
      options[:direction] = { buy: :sell, sell: :buy }.fetch(direction)
      options[:size] ||= size

      model = PositionCloseAttributes.build options
      model.validate

      body = RequestBodyFormatter.format model

      @dealing_platform.session.delete('positions/otc', body).fetch :deal_reference
    end

    # Updates this position. No attributes are mandatory, and any attributes not specified will be kept at their
    # current value.
    #
    # @param [Hash] new_attributes The attributes of this position to update.
    # @option new_attributes [Float] :limit_level The new limit level for this position.
    # @option new_attributes [Float] :stop_level The new stop level for this position.
    # @option new_attributes [Boolean] :trailing_stop Whether to use a trailing stop for this position.
    # @option new_attributes [Integer] :trailing_stop_distance The distance away in pips to place the trailing stop.
    # @option new_attributes [Integer] :trailing_stop_increment The step increment to use for the trailing stop.
    #
    # @return [String] The deal reference of the update operation. Use {DealingPlatform#deal_confirmation} to check
    #         the result of the position update.
    def update(new_attributes)
      new_attributes = { limit_level: limit_level, stop_level: stop_level, trailing_stop: trailing_stop?,
                         trailing_stop_distance: trailing_stop_distance, trailing_stop_increment: trailing_step }
                       .merge new_attributes

      unless new_attributes[:trailing_stop]
        new_attributes[:trailing_stop_distance] = new_attributes[:trailing_stop_increment] = nil
      end

      body = RequestBodyFormatter.format PositionUpdateAttributes.new(new_attributes)

      @dealing_platform.session.put("positions/otc/#{deal_id}", body, API_V2).fetch(:deal_reference)
    end

    # Validates the internal consistency of the `:order_type`, `:quote_id` and `:level` attributes.
    #
    # @param [Hash] attributes The attributes hash to validate.
    def self.validate_order_type_constraints(attributes)
      if (attributes[:order_type] == :quote) == attributes[:quote_id].nil?
        raise ArgumentError, 'set quote_id if and only if order_type is :quote'
      end

      if [:limit, :quote].include?(attributes[:order_type]) == attributes[:level].nil?
        raise ArgumentError, 'set level if and only if order_type is :limit or :quote'
      end
    end

    # Internal model used by {#close}.
    class PositionCloseAttributes < Model
      attribute :deal_id
      attribute :direction, Symbol, allowed_values: [:buy, :sell]
      attribute :level, Float
      attribute :order_type, Symbol, allowed_values: [:limit, :market, :quote]
      attribute :quote_id
      attribute :size, Float
      attribute :time_in_force, Symbol, allowed_values: [:execute_and_eliminate, :fill_or_kill]

      # Runs a series of validations on this model's attributes to check whether it is ready to be sent to the IG
      # Markets API.
      def validate
        [:deal_id, :direction, :order_type, :size, :time_in_force].each do |attribute|
          raise ArgumentError, "#{attribute} attribute must be set" if attributes[attribute].nil?
        end

        Position.validate_order_type_constraints attributes
      end

      # Builds a new {PositionCloseAttributes} instance with the given attributes and applies relevant defaults.
      #
      # @param [Hash] attributes
      #
      # @return [PositionCloseAttributes]
      def self.build(attributes)
        new(attributes).tap do |model|
          model.order_type ||= :market
          model.time_in_force = :execute_and_eliminate if model.order_type == :market
        end
      end
    end

    # Internal model used by {#update}.
    class PositionUpdateAttributes < Model
      attribute :limit_level, Float
      attribute :stop_level, Float
      attribute :trailing_stop, Boolean
      attribute :trailing_stop_distance, Integer
      attribute :trailing_stop_increment, Integer
    end

    private_constant :PositionCloseAttributes, :PositionUpdateAttributes
  end
end

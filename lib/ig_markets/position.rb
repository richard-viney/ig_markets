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

    # Closes this position, either partially or completely.
    #
    # @param [Hash] close_attributes The attributes for the new position.
    # @option close_attributes [Float] :level Required if and only if `:order_type` is `:limit` or `:quote`.
    # @option close_attributes [:limit, :market, :quote] :order_type The order type. `:market` indicates to fill the
    #                          order at current market level(s). `:limit` indicates to fill at the price specified by
    #                          `:level` (or a more favourable one). `:quote` is only permitted following agreement with
    #                          IG Markets.
    # @option close_attributes [String] :quote_id The Lightstreamer quote ID. Required when `:order_type` is `:quote`.
    # @option close_attributes [Float] :size The size of this position to close. Defaults to {#size}.
    # @option close_attributes [:execute_and_eliminate, :fill_or_kill] :time_in_force The order fill strategy.
    #                          `:execute_and_eliminate` will fill this order as much as possible within the constraints
    #                          set by `:order_type`, `:level` and `:quote_id`. `:fill_or_kill` will try to fill this
    #                          entire order within the constraints, however if this is not possible then the order will
    #                          not be filled at all. If `:order_type` is `:market` then `:time_in_force` will be
    #                          automatically set to `:execute_and_eliminate`.
    #
    # @return [String] The resulting deal reference, use {DealingPlatform#deal_confirmation} to check the result of
    #         the position close.
    def close(close_attributes)
      close_attributes[:deal_id] = deal_id
      close_attributes[:direction] = { buy: :sell, sell: :buy }.fetch(direction)
      close_attributes[:size] ||= size
      close_attributes[:time_in_force] = :execute_and_eliminate if close_attributes[:order_type] == :market

      model = PositionCloseAttributes.new close_attributes
      model.validate!

      payload = PayloadFormatter.format model

      @dealing_platform.session.delete('positions/otc', payload, API_V1).fetch(:deal_reference)
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
      def validate!
        validate_required_attributes_present!
        validate_order_type_constraints!
      end

      private

      def validate_required_attributes_present!
        [:deal_id, :direction, :order_type, :size, :time_in_force].each do |attribute|
          raise ArgumentError, "#{attribute} attribute must be set" if attributes[attribute].nil?
        end
      end

      def validate_order_type_constraints!
        if (order_type == :quote) == quote_id.nil?
          raise ArgumentError, 'set quote_id if and only if order_type is :quote'
        end

        if [:limit, :quote].include?(order_type) == level.nil?
          raise ArgumentError, 'set level if and only if order_type is :limit or :quote'
        end
      end
    end

    # Internal model used by {#update}.
    class PositionUpdateAttributes < Model
      attribute :limit_level, Float
      attribute :stop_level, Float
      attribute :trailing_stop, Boolean
      attribute :trailing_stop_distance, Fixnum
      attribute :trailing_stop_increment, Fixnum
    end

    private_constant :PositionCloseAttributes, :PositionUpdateAttributes
  end
end

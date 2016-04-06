module IGMarkets
  class DealingPlatform
    # Provides methods for working with positions. Returned by {DealingPlatform#positions}.
    class PositionMethods
      # Initializes this helper class with the specified dealing platform.
      #
      # @param [DealingPlatform] dealing_platform The dealing platform.
      def initialize(dealing_platform)
        @dealing_platform = dealing_platform
      end

      # Returns all positions.
      #
      # @return [Array<Position>]
      def all
        @dealing_platform.session.get('positions', API_V2).fetch(:positions).map do |attributes|
          position_from_attributes attributes
        end
      end

      # Returns the position with the specified deal ID, or `nil` if there is no position with that ID.
      #
      # @param [String] deal_id The deal ID of the working order to return.
      #
      # @return [Position]
      def [](deal_id)
        attributes = @dealing_platform.session.get "positions/#{deal_id}", API_V2

        position_from_attributes attributes
      end

      # Creates a new position.
      #
      # @param [Hash] attributes The attributes for the new position.
      # @option attributes [String] :currency_code The 3 character currency code, must be one of the instrument's
      #                    currencies (see {Instrument#currencies}). Required.
      # @option attributes [:buy, :sell] :direction The position direction. Required.
      # @option attributes [String] :epic The EPIC of the instrument to create a position for. Required.
      # @option attributes [DateTime] :expiry The expiry date of the instrument, if it has one. Optional.
      # @option attributes [Boolean] :force_open Whether a force open is required. Defaults to `false`.
      # @option attributes [Boolean] :guaranteed_stop Whether a guaranteed stop is required. Defaults to `false`.
      # @option attributes [Float] :level Required if and only if `:order_type` is `:limit` or `:quote`.
      # @option attributes [Fixnum] :limit_distance The distance away in pips to place the limit. If this is set then
      #                    `:limit_level` must be `nil`. Optional.
      # @option attributes [Float] :limit_level The limit level. If this is set then `:limit_distance` must be `nil`.
      #                    Optional.
      # @option attributes [:limit, :market, :quote] :order_type The order type. `:market` indicates to fill the order
      #                    at current market level(s). `:limit` indicates to fill at the price specified by `:level`
      #                    (or a more favorable one). `:quote` is only permitted following agreement with IG Markets.
      #                    Defaults to `:market`.
      # @option attributes [String] :quote_id The Lightstreamer quote ID. Required when `:order_type` is `:quote`.
      # @option attributes [Float] :size The size of the position to create. Required.
      # @option attributes [Fixnum] :stop_distance The distance away in pips to place the stop. If this is set then
      #                    `:stop_level` must be `nil`. Optional.
      # @option attributes [Float] :stop_level The stop level. If this is set then `:stop_distance` must be `nil`.
      #                    Optional.
      # @option attributes [:execute_and_eliminate, :fill_or_kill] :time_in_force The order fill strategy.
      #                    `:execute_and_eliminate` will fill this order as much as possible within the constraints set
      #                    by `:order_type`, `:level` and `:quote_id`, which may result in only part of the requested
      #                    order being filled. `:fill_or_kill` will try to fill the whole order within the constraints,
      #                    however if this is not possible then the order will not be filled at all. If `:order_type` is
      #                    `:market` (the default) then `:time_in_force` will be automatically set to
      #                    `:execute_and_eliminate`.
      # @option attributes [Boolean] :trailing_stop Whether to use a trailing stop. Defaults to false. Optional.
      # @option attributes [Fixnum] :trailing_stop_increment The increment step in pips for the trailing stop. Required
      #                    when `:trailing_stop` is `true`.
      #
      # @return [String] The resulting deal reference, use {DealingPlatform#deal_confirmation} to check the result of
      #         the position creation.
      def create(attributes)
        attributes[:force_open] = false unless attributes.key? :force_open
        attributes[:guaranteed_stop] = false unless attributes.key? :guaranteed_stop
        attributes[:order_type] ||= :market
        attributes[:time_in_force] = :execute_and_eliminate if attributes[:order_type] == :market

        model = PositionCreateAttributes.new attributes
        model.validate

        payload = PayloadFormatter.format model
        payload[:expiry] ||= '-'

        @dealing_platform.session.post('positions/otc', payload, API_V2).fetch(:deal_reference)
      end

      private

      # Internal model used by {#create}
      class PositionCreateAttributes < Model
        attribute :currency_code, String, regex: Regex::CURRENCY
        attribute :direction, Symbol, allowed_values: [:buy, :sell]
        attribute :epic, String, regex: Regex::EPIC
        attribute :expiry, DateTime, format: '%d-%b-%y'
        attribute :force_open, Boolean
        attribute :guaranteed_stop, Boolean
        attribute :level, Float
        attribute :limit_distance, Fixnum
        attribute :limit_level, Float
        attribute :order_type, Symbol, allowed_values: [:limit, :market, :quote]
        attribute :quote_id
        attribute :size, Fixnum
        attribute :stop_distance, Fixnum
        attribute :stop_level, Float
        attribute :time_in_force, Symbol, allowed_values: [:execute_and_eliminate, :fill_or_kill]
        attribute :trailing_stop, Boolean
        attribute :trailing_stop_increment, Fixnum

        # Runs a series of validations on this model's attributes to check whether it is ready to be sent to the IG
        # Markets API.
        def validate
          validate_required_attributes_present
          Position.validate_order_type_constraints attributes
          validate_trailing_stop_constraints
          validate_stop_and_limit_constraints
          validate_guaranteed_stop_constraints
        end

        private

        # Checks that all required attributes for position creation are present.
        def validate_required_attributes_present
          required = [:currency_code, :direction, :epic, :force_open, :guaranteed_stop, :order_type, :size,
                      :time_in_force]

          required.each do |attribute|
            raise ArgumentError, "#{attribute} attribute must be set" if attributes[attribute].nil?
          end
        end

        # Checks that attributes associated with the trailing stops are valid.
        def validate_trailing_stop_constraints
          if trailing_stop
            raise ArgumentError, 'do not set stop_level when trailing_stop is true' if stop_level
            raise ArgumentError, 'set stop_distance when trailing_stop is true' unless stop_distance
          end

          if trailing_stop == trailing_stop_increment.nil?
            raise ArgumentError, 'set trailing_stop_increment if and only if trailing_stop is true'
          end
        end

        # Checks that attributes associated with the stop and limit are valid.
        def validate_stop_and_limit_constraints
          raise ArgumentError, 'set only one of limit_level and limit_distance' if limit_level && limit_distance
          raise ArgumentError, 'set only one of stop_level and stop_distance' if stop_level && stop_distance
        end

        # Checks that attributes associated with the guaranteed stop are valid.
        def validate_guaranteed_stop_constraints
          if guaranteed_stop && !(stop_level.nil? ^ stop_distance.nil?)
            raise ArgumentError, 'set exactly one of stop_level or stop_distance when guaranteed_stop is true'
          end
        end
      end

      def position_from_attributes(attributes)
        Position.new(attributes.fetch(:position).merge(market: attributes.fetch(:market))).tap do |position|
          position.instance_variable_set :@dealing_platform, @dealing_platform
        end
      end

      private_constant :PositionCreateAttributes
    end
  end
end

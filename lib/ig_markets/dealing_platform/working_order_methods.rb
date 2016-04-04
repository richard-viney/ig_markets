module IGMarkets
  class DealingPlatform
    # Provides methods for interacting with working orders. Returned by {DealingPlatform#working_orders}.
    class WorkingOrderMethods
      # Initializes this helper class with the specified dealing platform.
      #
      # @param [DealingPlatform] dealing_platform The dealing platform.
      def initialize(dealing_platform)
        @dealing_platform = dealing_platform
      end

      # Returns all working orders.
      #
      # @return [Array<WorkingOrder>]
      def all
        @dealing_platform.session.get('workingorders', API_V2).fetch(:working_orders).map do |attributes|
          attributes = attributes.fetch(:working_order_data).merge(market: attributes.fetch(:market_data))

          WorkingOrder.new(attributes).tap do |working_order|
            working_order.instance_variable_set :@dealing_platform, @dealing_platform
          end
        end
      end

      # Returns the working order with the specified deal ID.
      #
      # @param [String] deal_id The deal ID of the working order to return.
      #
      # @return [WorkingOrder] The order with the specified deal ID, or `nil` if there is no order with that ID.
      def [](deal_id)
        all.detect do |working_order|
          working_order.deal_id == deal_id
        end
      end

      # Creates a new working order with the specified attributes.
      #
      # @param [Hash] attributes The attributes for the new working order.
      # @option attributes [String] :currency_code Three character currency code. Required.
      # @option attributes [:buy, :sell] :direction Order direction. Required.
      # @option attributes [String] :epic EPIC of the instrument for this order. Required.
      # @option attributes [DateTime] :expiry The expiry date of the instrument (if applicable). Optional.
      # @option attributes [Boolean] :force_open Defaults to `false`.
      # @option attributes [DateTime] :good_till_date Must be set if `:time_in_force` is `:good_till_date`.
      # @option attributes [Boolean] :guaranteed_stop Defaults to `false`.
      # @option attributes [Float] :level Required.
      # @option attributes [Float] :limit_distance Distance away in pips to place the limit. Optional.
      # @option attributes [Float] :size Size of the working order. Required.
      # @option attributes [Float] :stop_distance Distance away in pips to place the stop. Optional.
      # @option attributes [:good_till_cancelled, :good_till_date] :time_in_force Defaults to `:good_till_cancelled`.
      # @option attributes [:limit, :stop] :type Required.
      #
      # @return [String] The resulting deal reference, use {DealingPlatform#deal_confirmation} to check the result of
      #         the working order creation.
      def create(attributes)
        attributes[:force_open] ||= false
        attributes[:guaranteed_stop] ||= false
        attributes[:time_in_force] ||= :good_till_cancelled

        model = build_working_order_model attributes

        payload = PayloadFormatter.format model

        payload[:expiry] = '-' if payload[:expiry].nil?

        @dealing_platform.session.post('workingorders/otc', payload, API_V2).fetch(:deal_reference)
      end

      private

      def build_working_order_model(attributes)
        model = WorkingOrderCreateAttributes.new attributes

        required = [:currency_code, :direction, :epic, :guaranteed_stop, :level, :size, :time_in_force, :type]
        required.each do |attribute|
          raise ArgumentError, "#{attribute} attribute must be set" if attributes[attribute].nil?
        end

        if model.time_in_force == :good_till_date && !model.good_till_date.is_a?(DateTime)
          raise ArgumentError, 'good_till_date attribute must be set when time_in_force is :good_till_date'
        end

        model
      end

      # Internal model used by {#create}.
      class WorkingOrderCreateAttributes < Model
        attribute :currency_code, String, regex: Regex::CURRENCY
        attribute :direction, Symbol, allowed_values: [:buy, :sell]
        attribute :epic, String, regex: Regex::EPIC
        attribute :expiry, DateTime, format: '%y-%^b-%d'
        attribute :force_open, Boolean
        attribute :good_till_date, DateTime, format: '%Y-%m-%d %H:%M:%S'
        attribute :guaranteed_stop, Boolean
        attribute :level, Float
        attribute :limit_distance, Float
        attribute :size, Float
        attribute :stop_distance, Float
        attribute :time_in_force, Symbol, allowed_values: [:good_till_cancelled, :good_till_date]
        attribute :type, Symbol, allowed_values: [:limit, :stop]
      end

      private_constant :WorkingOrderCreateAttributes
    end
  end
end

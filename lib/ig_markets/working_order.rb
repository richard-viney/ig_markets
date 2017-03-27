module IGMarkets
  # Contains details on a working order. Returned by {DealingPlatform::WorkingOrderMethods#all} and
  # {DealingPlatform::WorkingOrderMethods#[]}.
  class WorkingOrder < Model
    attribute :created_date_utc, Time, format: '%FT%T'
    attribute :currency_code, String, regex: Regex::CURRENCY
    attribute :deal_id
    attribute :direction, Symbol, allowed_values: %i(buy sell)
    attribute :dma, Boolean
    attribute :epic, String, regex: Regex::EPIC
    attribute :good_till_date, Time, format: '%Y/%m/%d %R'
    attribute :guaranteed_stop, Boolean
    attribute :limit_distance, Integer
    attribute :limited_risk_premium, LimitedRiskPremium
    attribute :order_level, Float
    attribute :order_size, Float
    attribute :order_type, Symbol, allowed_values: %i(limit stop)
    attribute :stop_distance, Integer
    attribute :time_in_force, Symbol, allowed_values: %i(good_till_cancelled good_till_date)

    attribute :market, MarketOverview

    deprecated_attribute :created_date, :good_till_date_iso

    # Reloads this working order's attributes by re-querying the IG Markets API.
    def reload
      self.attributes = @dealing_platform.working_orders[deal_id].attributes
    end

    # Deletes this working order.
    #
    # @return [String] The deal reference of the deletion operation. Use {DealingPlatform#deal_confirmation} to check
    #         the result of the working order deletion.
    def delete
      @dealing_platform.session.delete("workingorders/otc/#{deal_id}", nil, API_V2).fetch(:deal_reference)
    end

    # Updates this working order. No attributes are mandatory, and any attributes not specified will be kept at their
    # current values.
    #
    # @param [Hash] new_attributes The attributes of this working order to update. See
    #        {DealingPlatform::WorkingOrderMethods#create} for a description of the attributes.
    # @option new_attributes [Time] :good_till_date
    # @option new_attributes [Float] :level
    # @option new_attributes [Integer] :limit_distance
    # @option new_attributes [Float] :limit_level
    # @option new_attributes [Integer] :stop_distance
    # @option new_attributes [Float] :stop_level
    # @option new_attributes [:limit, :stop] :type
    #
    # @return [String] The deal reference of the update operation. Use {DealingPlatform#deal_confirmation} to check
    #         the result of the working order update.
    def update(new_attributes)
      existing_attributes = { good_till_date: good_till_date, level: order_level, limit_distance: limit_distance,
                              stop_distance: stop_distance, time_in_force: time_in_force, type: order_type }

      model = WorkingOrderUpdateAttributes.new existing_attributes, new_attributes
      model.validate

      body = RequestBodyFormatter.format model

      @dealing_platform.session.put("workingorders/otc/#{deal_id}", body, API_V2).fetch(:deal_reference)
    end

    # Internal model used by {#update}.
    class WorkingOrderUpdateAttributes < Model
      attribute :good_till_date, Time, format: '%Y/%m/%d %R:%S'
      attribute :level, Float
      attribute :limit_distance, Integer
      attribute :limit_level, Float
      attribute :stop_distance, Integer
      attribute :stop_level, Float
      attribute :time_in_force, Symbol, allowed_values: %i(good_till_cancelled good_till_date)
      attribute :type, Symbol, allowed_values: %i(limit stop)

      def initialize(existing_attributes, new_attributes)
        existing_attributes.delete :limit_distance if new_attributes.key? :limit_level
        existing_attributes.delete :stop_distance if new_attributes.key? :stop_level

        super existing_attributes.merge(new_attributes)

        self.time_in_force = good_till_date ? :good_till_date : :good_till_cancelled
      end

      # Runs a series of validations on this model's attributes to check whether it is ready to be sent to the IG
      # Markets API.
      def validate
        if limit_distance && limit_level
          raise ArgumentError, 'do not specify both limit_distance and limit_level'
        end

        raise ArgumentError, 'do not specify both stop_distance and stop_level' if stop_distance && stop_level
      end
    end

    private_constant :WorkingOrderUpdateAttributes
  end
end

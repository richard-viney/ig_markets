module IGMarkets
  # Contains details on a working order. Returned by {DealingPlatform::WorkingOrderMethods#all} and
  # {DealingPlatform::WorkingOrderMethods#[]}.
  class WorkingOrder < Model
    attribute :created_date_utc, Time, format: '%FT%T'
    attribute :currency_code, String, regex: Regex::CURRENCY
    attribute :deal_id
    attribute :direction, Symbol, allowed_values: [:buy, :sell]
    attribute :dma, Boolean
    attribute :epic, String, regex: Regex::EPIC
    attribute :good_till_date, Time, format: '%Y/%m/%d %R'
    attribute :guaranteed_stop, Boolean
    attribute :limit_distance, Fixnum
    attribute :order_level, Float
    attribute :order_size, Float
    attribute :order_type, Symbol, allowed_values: [:limit, :stop]
    attribute :stop_distance, Fixnum
    attribute :time_in_force, Symbol, allowed_values: [:good_till_cancelled, :good_till_date]

    attribute :market, MarketOverview

    deprecated_attribute :created_date, :good_till_date_iso

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
    # @option new_attributes [Fixnum] :limit_distance
    # @option new_attributes [Fixnum] :stop_distance
    # @option new_attributes [:limit, :stop] :type
    #
    # @return [String] The deal reference of the update operation. Use {DealingPlatform#deal_confirmation} to check
    #         the result of the working order update.
    def update(new_attributes)
      new_attributes = { good_till_date: good_till_date, level: order_level, limit_distance: limit_distance,
                         stop_distance: stop_distance, time_in_force: time_in_force, type: order_type
                       }.merge new_attributes

      new_attributes[:time_in_force] = new_attributes[:good_till_date] ? :good_till_date : :good_till_cancelled

      payload = PayloadFormatter.format WorkingOrderUpdateAttributes.new new_attributes

      @dealing_platform.session.put("workingorders/otc/#{deal_id}", payload).fetch(:deal_reference)
    end

    # Internal model used by {#update}.
    class WorkingOrderUpdateAttributes < Model
      attribute :good_till_date, Time, format: '%Y/%m/%d %R:%S'
      attribute :level, Float
      attribute :limit_distance, Fixnum
      attribute :stop_distance, Fixnum
      attribute :time_in_force, Symbol, allowed_values: [:good_till_cancelled, :good_till_date]
      attribute :type, Symbol, allowed_values: [:limit, :stop]
    end

    private_constant :WorkingOrderUpdateAttributes
  end
end

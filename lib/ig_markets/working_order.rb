module IGMarkets
  # Contains details on a working order. See {DealingPlatform::WorkingOrderMethods} for usage details.
  class WorkingOrder < Model
    attribute :created_date, DateTime, format: '%Y/%m/%d %H:%M:%S:%L'
    attribute :created_date_utc, DateTime, format: '%Y-%m-%dT%H:%M:%S'
    attribute :currency_code, String, regex: Regex::CURRENCY
    attribute :deal_id
    attribute :direction, Symbol, allowed_values: [:buy, :sell]
    attribute :dma, Boolean
    attribute :epic, String, regex: Regex::EPIC
    attribute :good_till_date, DateTime, format: '%Y/%m/%d %H:%M'
    attribute :good_till_date_iso, DateTime, format: '%Y-%m-%dT%H:%M'
    attribute :guaranteed_stop, Boolean
    attribute :limit_distance, Fixnum
    attribute :order_level, Float
    attribute :order_size, Float
    attribute :order_type, Symbol, allowed_values: [:limit, :stop]
    attribute :stop_distance, Fixnum
    attribute :time_in_force, Symbol, allowed_values: [:good_till_cancelled, :good_till_date]

    attribute :market, MarketOverview

    # Deletes this working order.
    #
    # @return [String] The deal reference of the deletion operation. Use {DealingPlatform#deal_confirmation} to check
    #                  the result of the working order deletion.
    def delete
      @dealing_platform.session.delete("workingorders/otc/#{deal_id}", {}, API_V1).fetch(:deal_reference)
    end

    # Updates this working order. No attributes are mandatory, and any attributes not updated will be kept at the
    # current value they have on this class.
    #
    # @param [Hash] new_attributes The attributes of this working order to update.
    # @option new_attributes [DateTime] :good_till_date Required if `:time_in_force` is `:good_till_date`.
    # @option new_attributes [Float] :level
    # @option new_attributes [Float] :limit_distance Distance away in pips to place the limit.
    # @option new_attributes [Float] :stop_distance Distance away in pips to place the stop.
    # @option new_attributes [:good_till_cancelled, :good_till_date] :time_in_force
    # @option new_attributes [:limit, :stop] :type
    #
    # @return [String] The deal reference of the update operation. Use {DealingPlatform#deal_confirmation} to check
    #                  the result of the working order update.
    def update(new_attributes)
      new_attributes = { good_till_date: good_till_date, level: order_level, limit_distance: limit_distance,
                         stop_distance: stop_distance, time_in_force: time_in_force, type: order_type
                       }.merge new_attributes

      payload = PayloadFormatter.format WorkingOrderUpdateAttributes.new new_attributes

      @dealing_platform.session.put("workingorders/otc/#{deal_id}", payload, API_V1).fetch(:deal_reference)
    end

    # Internal model used by {#update}.
    class WorkingOrderUpdateAttributes < Model
      attribute :good_till_date, DateTime, format: '%Y/%m/%d %H:%M'
      attribute :limit_distance, Float
      attribute :level, Float
      attribute :type, Symbol, allowed_values: [:limit, :stop]
      attribute :stop_distance, Float
      attribute :time_in_force, Symbol, allowed_values: [:good_till_cancelled, :good_till_date]
    end

    private_constant :WorkingOrderUpdateAttributes
  end
end

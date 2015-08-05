module IGMarkets
  module AttributeTypecasters
    def account_balance
      ->(attributes) { IGMarkets::AccountBalance.from attributes }
    end

    def boolean
      ->(value) { { true => true, false => false }.fetch(value) }
    end

    def currencies
      ->(o) { o.map { |attributes| Currency.from attributes } }
    end

    def date_time(format_string)
      lambda do |value|
        if value.is_a?(String)
          value == '' ? nil : DateTime.strptime(value, format_string)
        else
          value
        end
      end
    end

    def float
      ->(value) { value && Float(value) }
    end

    def instrument_expiry_details
      ->(attributes) { InstrumentExpiryDetails.from attributes }
    end

    def instrument_rollover_details
      ->(attributes) { InstrumentRolloverDetails.from attributes }
    end

    def instrument_slippage_factor
      ->(attributes) { InstrumentSlippageFactor.from attributes }
    end

    def margin_deposit_bands
      ->(o) { o.map { |attributes| MarginDepositBand.from attributes } }
    end

    def market
      ->(attributes) { Market.from attributes }
    end

    def opening_hours
      lambda do |o|
        (o.is_a?(Hash) ? o.fetch(:market_times) : o).map { |attributes| OpeningHours.from attributes }
      end
    end

    def price
      ->(attributes) { Price.from attributes }
    end

    module_function :account_balance, :boolean, :currencies, :date_time, :float, :instrument_expiry_details,
                    :instrument_rollover_details, :instrument_slippage_factor, :margin_deposit_bands, :market,
                    :opening_hours, :price
  end
end

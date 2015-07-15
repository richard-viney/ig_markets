module IGMarkets
  module AttributeTypecasters
    def account_balance
      ->(attributes) { IGMarkets::AccountBalance.from attributes }
    end

    def currencies
      ->(o) { o.map { |attributes| Currency.from attributes } }
    end

    def date_time(format_string)
      lambda do |value|
        value.is_a?(String) ? DateTime.strptime(value, format_string) : value
      end
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

    module_function :account_balance, :currencies, :date_time, :instrument_expiry_details, :instrument_rollover_details,
                    :instrument_slippage_factor, :margin_deposit_bands, :market, :opening_hours, :price
  end
end

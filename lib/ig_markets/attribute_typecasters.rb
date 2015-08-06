module IGMarkets
  module AttributeTypecasters
    def account_balance(value, options)
      IGMarkets::AccountBalance.from value
    end

    def boolean(value, options)
      { true => true, false => false }.fetch(value)
    end

    def currencies(value, options)
      value.map { |attributes| Currency.from attributes }
    end

    def date_time(value, options)
      if value.is_a?(String)
        value == '' ? nil : DateTime.strptime(value, options.fetch(:format))
      else
        value
      end
    end

    def float(value, options)
      value && Float(value)
    end

    def instrument_expiry_details(value, options)
      InstrumentExpiryDetails.from value
    end

    def instrument_rollover_details(value, options)
      InstrumentRolloverDetails.from value
    end

    def instrument_slippage_factor(value, options)
      InstrumentSlippageFactor.from value
    end

    def margin_deposit_bands(value, options)
      value.map { |attributes| MarginDepositBand.from attributes }
    end

    def market(value, options)
      Market.from value
    end

    def opening_hours(value, options)
      (value.is_a?(Hash) ? value.fetch(:market_times) : value).map { |attributes| OpeningHours.from attributes }
    end

    def price(value, options)
      Price.from value
    end

    module_function :account_balance, :boolean, :currencies, :date_time, :float, :instrument_expiry_details,
                    :instrument_rollover_details, :instrument_slippage_factor, :margin_deposit_bands, :market,
                    :opening_hours, :price
  end
end

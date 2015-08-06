module IGMarkets
  module AttributeTypecasters
    module_function

    def account_balance(value)
      IGMarkets::AccountBalance.from value
    end

    def boolean(value)
      { true => true, false => false }.fetch(value)
    end

    def currencies(value)
      value.map { |attributes| Currency.from attributes }
    end

    def date_time(value, options)
      if value.is_a?(String)
        value == '' ? nil : DateTime.strptime(value, options.fetch(:format))
      else
        value
      end
    end

    def float(value)
      value && Float(value)
    end

    def instrument_expiry_details(value)
      InstrumentExpiryDetails.from value
    end

    def instrument_rollover_details(value)
      InstrumentRolloverDetails.from value
    end

    def instrument_slippage_factor(value)
      InstrumentSlippageFactor.from value
    end

    def margin_deposit_bands(value)
      value.map { |attributes| MarginDepositBand.from attributes }
    end

    def market(value)
      Market.from value
    end

    def opening_hours(value)
      (value.is_a?(Hash) ? value.fetch(:market_times) : value).map { |attributes| OpeningHours.from attributes }
    end

    def price(value)
      Price.from value
    end
  end
end

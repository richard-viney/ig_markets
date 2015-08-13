module IGMarkets
  module AttributeTypecasters
    module_function

    def account_balance(value)
      IGMarkets::AccountBalance.from value
    end

    def boolean(value)
      return value if [nil, true, false].include? value

      fail ArgumentError, "Invalid boolean value: #{value}"
    end

    def currencies(value)
      Array(value).map do |attributes|
        Currency.from attributes
      end
    end

    def date_time(value, options)
      fail ArgumentError, 'Invalid or missing date time format' unless options[:format].is_a? String

      value = nil if value == ''

      if value.is_a? String
        DateTime.strptime(value, options[:format])
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
      Array(value).map do |attributes|
        MarginDepositBand.from attributes
      end
    end

    def market(value)
      Market.from value
    end

    def opening_hours(value)
      Array(value.is_a?(Hash) ? value.fetch(:market_times) : value).map do |attributes|
        OpeningHours.from attributes
      end
    end

    def price(value)
      Price.from value
    end
  end
end

module IGMarkets
  module AttributeTypecasters
    def account_balance
      ->(attributes) { IGMarkets::AccountBalance.new attributes }
    end

    def currencies
      ->(o) { o.map { |attributes| Currency.new attributes } }
    end

    def instrument_expiry_details
      ->(attributes) { InstrumentExpiryDetails.new attributes }
    end

    def instrument_rollover_details
      ->(attributes) { InstrumentRolloverDetails.new attributes }
    end

    def instrument_slippage_factor
      ->(attributes) { InstrumentSlippageFactor.new attributes }
    end

    def margin_deposit_bands
      ->(o) { o.map { |attributes| MarginDepositBand.new attributes } }
    end

    def market
      ->(attributes) { Market.new attributes }
    end

    def opening_hours
      ->(o) { o.fetch(:market_times).map { |attributes| OpeningHours.new attributes } }
    end

    def price
      ->(attributes) { Price.new attributes }
    end

    module_function :account_balance, :currencies, :instrument_expiry_details, :instrument_rollover_details,
                    :instrument_slippage_factor, :margin_deposit_bands, :market, :opening_hours, :price
  end
end

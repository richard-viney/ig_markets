module IGMarkets
  module Validate
    def currency_code!(currency_code)
      fail ArgumentError, 'currency code is invalid' unless currency_code.to_s =~ /\A[A-Z]{3}\Z/
    end

    def epic!(*epics)
      epics.flatten.each do |epic|
        fail ArgumentError, 'epic is invalid' unless epic.to_s =~ /\A[A-Z,a-z,0-9,.,_]{6,30}\Z/
      end
    end

    HISTORICAL_PRICE_RESOLUTIONS = [
      :minute, :minute_2, :minute_3, :minute_5, :minute_10, :minute_15, :minute_30,
      :hour, :hour_2, :hour_3, :hour_4,
      :day, :week, :month
    ]

    def historical_price_resolution!(resolution)
      fail ArgumentError, 'resolution is invalid' unless HISTORICAL_PRICE_RESOLUTIONS.include? resolution
    end

    TRANSACTION_TYPES = [:all, :all_deal, :deposit, :withdrawal]

    def transaction_type!(type)
      fail ArgumentError, 'transaction type is invalid' unless TRANSACTION_TYPES.include? type
    end

    module_function :currency_code!, :epic!, :historical_price_resolution!, :transaction_type!
  end
end

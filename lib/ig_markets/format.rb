module IGMarkets
  # This module contains shared methods for formatting different content types for display.
  module Format
    module_function

    # Returns a formatted string for the specified price in the given currency. Four decimal places are used for
    # all currencies except the Japanese Yen where two are used.
    #
    # @param [Float, Fixnum] level The price level to format.
    # @param [String] currency The currency.
    #
    # @return [String] The formatted level, e.g. `"-130.4055"`, `"3560.60"`.
    def price(level, currency)
      return '' unless level

      if ['JPY', '¥'].include? currency
        format '%.2f  ', level.to_f
      else
        format '%.4f', level.to_f
      end
    end

    # Returns a formatted string for the specified currency amount and currency. Two decimal places are used for all
    # currencies except the Japanese Yen.
    #
    # @param [Float, Fixnum] amount The currency amount to format.
    # @param [String] currency The currency.
    #
    # @return [String] The formatted currency amount, e.g. `"USD -130.40"`, `"AUD 539.10"`, `"JPY 3560"`.
    def currency(amount, currency)
      return '' unless amount

      if ['JPY', '¥'].include? currency
        "#{currency} #{format '%i', amount.to_i}"
      else
        "#{currency} #{format '%.2f', amount.to_f}"
      end
    end

    # Returns a formatted string for the specified number of seconds in the format `[<hours>:]<minutes>:<seconds>`.
    #
    # @param [Fixnum] value The number of seconds to format.
    #
    # @return [String]
    def seconds(value)
      result = if value >= 60 * 60
                 "#{value / 60 / 60}:#{Kernel.format('%02i', (value / 60) % 60)}"
               else
                 (value / 60).to_s
               end

      result + ':' + Kernel.format('%02i', value % 60)
    end
  end
end

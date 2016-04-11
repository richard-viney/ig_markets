module IGMarkets
  # This module contains shared methods for formatting different content types for display.
  module Format
    module_function

    # Returns a formatted string for the specified currency amount and currency symbol. Two decimal places are used for
    # all currencies except the Japanese Yen.
    #
    # @param [Float, Fixnum] amount The currency amount to format.
    # @param [String] symbol The currency symbol.
    #
    # @return [String] The formatted currency amount, e.g. `"USD -130.40"`, `"AUD 539.10"`, `"JPY 3560"`.
    def currency(amount, symbol)
      if ['JPY', '¥'].include? symbol
        "#{symbol} #{format '%i', amount.to_i}"
      else
        "#{symbol} #{format '%.2f', amount.to_f}"
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

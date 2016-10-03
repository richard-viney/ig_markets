module IGMarkets
  # This module contains shared methods for formatting different content types for display.
  #
  # @private
  module Format
    module_function

    # Returns a formatted string for the specified level. At most four decimal places are used to format levels.
    #
    # @param [Float] value The level to format.
    #
    # @return [String] The formatted level, e.g. `"-130.4055"`
    def level(value)
      return '' unless value

      Float(format('%.4f', value.to_f)).to_s
    end

    # Returns a formatted string for the specified currency amount and currency. Two decimal places are used for all
    # currencies except the Japanese Yen.
    #
    # @param [Float, Integer] amount The currency amount to format.
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
    # @param [Integer] value The number of seconds to format.
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

    # Formats the passed symbol into a human-readable string, replacing underscores with spaces and capitalizing the
    # first letter.
    #
    # @param [Symbol] value The symbol to format.
    #
    # @return [String]
    def symbol(value)
      value.to_s.capitalize.tr '_', ' '
    end
  end
end

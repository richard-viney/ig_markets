module IGMarkets
  # Contains methods for formatting payloads that can be passed to the IG Markets API.
  module PayloadFormatter
    module_function

    # Takes a {Model} and returns its attributes in a hash ready to be passed as a payload to the IG Markets API.
    # Attribute names will be converted to use camel case rather than snake case, `Symbol` attributes will be converted
    # to strings and will be uppercased, and both `Date` and `Time` attributes will be converted to strings using their
    # ':format' option.
    #
    # @param [Model] model The model instance to convert attributes for.
    #
    # @return [Hash] The resulting attributes hash.
    def format(model)
      model.class.defined_attributes.each_with_object({}) do |(name, options), formatted|
        value = model.send name

        next if value.nil?

        formatted[snake_case_to_camel_case(name)] = format_value value, options
      end
    end

    # Formats an individual value, see {#format} for details.
    #
    # @param value The attribute value to format.
    # @param options The options hash for the attribute.
    #
    # @return [String]
    def format_value(value, options)
      return value.to_s.upcase if options[:type] == Symbol

      value = value.utc if options[:type] == Time

      return value.strftime(options.fetch(:format)) if [Date, Time].include? options[:type]

      value
    end

    # Takes a string or symbol that uses snake case and converts it to a camel case symbol.
    #
    # @param [String, Symbol] value The string or symbol to convert to camel case.
    #
    # @return [Symbol]
    def snake_case_to_camel_case(value)
      pieces = value.to_s.split '_'

      (pieces[0] + pieces[1..-1].map(&:capitalize).join).to_sym
    end
  end
end

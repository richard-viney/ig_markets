module IGMarkets
  # Contains methods for formatting request bodies that can be passed to the IG Markets API.
  #
  # @private
  module RequestBodyFormatter
    module_function

    # Takes a {Model} and returns its attributes in a hash ready to be passed as a request body to the IG Markets API.
    # Attribute names will be converted from snake case to camel case, `Symbol` attributes will be converted to strings
    # and will be uppercased, and both `Date` and `Time` attributes will be converted to strings using their first
    # available `:format` option.
    #
    # @param [Model] model The model instance to convert attributes for.
    # @param [Hash] defaults The default attribute values to return, can be overridden by values set on `model`.
    #
    # @return [Hash] The resulting attributes hash.
    def format(model, defaults = {})
      model.class.defined_attributes.each_with_object(defaults.dup) do |(name, options), formatted|
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

      return value.strftime(Array(options.fetch(:format)).first) if [Date, Time].include? options[:type]

      value
    end

    # Takes a string or symbol that uses snake case and converts it to a camel case symbol.
    #
    # @param [String, Symbol] value The string or symbol to convert to camel case.
    #
    # @return [Symbol]
    def snake_case_to_camel_case(value)
      pieces = value.to_s.split '_'

      (pieces.first + pieces[1..].map(&:capitalize).join).to_sym
    end
  end
end
